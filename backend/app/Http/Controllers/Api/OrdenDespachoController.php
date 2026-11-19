<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OrdenDespacho;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use App\Services\ServicioSalidaInventario;

class OrdenDespachoController extends Controller
{
    // Consultar las órdenes de despacho registradas.
    public function index(): JsonResponse
    {
        $ordenes = OrdenDespacho::query()
            ->with([
                'almacen',
                'detalles.producto',
            ])
            ->orderByDesc('id')
            ->paginate(20);

        return response()->json($ordenes);
    }

    // Consultar una orden específica.
    public function show(OrdenDespacho $ordenDespacho): JsonResponse
    {
        $ordenDespacho->load([
            'almacen',
            'detalles.producto',
        ]);

        return response()->json($ordenDespacho);
    }

    // Crear una orden de despacho sin descontar inventario.
    public function store(Request $request): JsonResponse
    {
        $datos = $request->validate([
            'almacen_id' => [
                'required',
                'integer',
                'exists:almacenes,id',
            ],
            'destinatario' => [
                'required',
                'string',
                'max:150',
            ],
            'direccion_destino' => [
                'required',
                'string',
                'max:255',
            ],
            'observacion' => [
                'nullable',
                'string',
            ],
            'productos' => [
                'required',
                'array',
                'min:1',
            ],
            'productos.*.producto_id' => [
                'required',
                'integer',
                'distinct',
                'exists:productos,id',
            ],
            'productos.*.cantidad' => [
                'required',
                'integer',
                'min:1',
            ],
        ]);

        $orden = DB::transaction(function () use ($datos) {

            // Verificar que el almacén esté activo.
            $almacenActivo = DB::table('almacenes')
                ->where('id', $datos['almacen_id'])
                ->where('activo', true)
                ->exists();

            if (!$almacenActivo) {
                throw ValidationException::withMessages([
                    'almacen_id' => [
                        'El almacén seleccionado no está activo.',
                    ],
                ]);
            }

            // Registrar primero la orden pendiente.
            // El número definitivo se genera a partir de su ID.
            $orden = OrdenDespacho::create([
                'numero_orden' => 'TMP-' . bin2hex(random_bytes(12)),
                'almacen_id' => $datos['almacen_id'],
                'destinatario' => $datos['destinatario'],
                'direccion_destino' => $datos['direccion_destino'],
                'estado' => 'pendiente',
                'observacion' => $datos['observacion'] ?? null,
            ]);

            $orden->update([
                'numero_orden' => sprintf(
                    'OD-%06d',
                    $orden->id
                ),
            ]);

            // Registrar los productos solicitados.
            foreach ($datos['productos'] as $producto) {
                $orden->detalles()->create([
                    'producto_id' => $producto['producto_id'],
                    'cantidad' => $producto['cantidad'],
                ]);
            }

            return $orden->load([
                'almacen',
                'detalles.producto',
            ]);

        }, 3);

        return response()->json([
            'mensaje' => 'Orden de despacho creada correctamente.',
            'datos' => $orden,
        ], 201);
    }


    // Confirmar una orden y descontar sus productos del inventario.
    public function confirmarDespacho(
        OrdenDespacho $ordenDespacho,
        ServicioSalidaInventario $servicioSalida
    ): JsonResponse {

        $orden = DB::transaction(function () use (
            $ordenDespacho,
            $servicioSalida
        ) {

            // Bloquear la orden para impedir confirmaciones simultáneas.
            $orden = OrdenDespacho::query()
                ->lockForUpdate()
                ->findOrFail($ordenDespacho->id);

            if ($orden->estado !== 'pendiente') {
                throw ValidationException::withMessages([
                    'estado' => [
                        'Solo se pueden despachar órdenes pendientes.',
                    ],
                ]);
            }

            // Verificar que la orden tenga productos.
            $detalles = $orden->detalles()
                ->orderBy('producto_id')
                ->get();

            if ($detalles->isEmpty()) {
                throw ValidationException::withMessages([
                    'productos' => [
                        'La orden no contiene productos para despachar.',
                    ],
                ]);
            }

            // Procesar cada producto dentro de la misma transacción.
            foreach ($detalles as $detalle) {

                $servicioSalida->registrarSalida(
                    (int) $detalle->producto_id,
                    (int) $orden->almacen_id,
                    (int) $detalle->cantidad,
                    $orden->numero_orden,
                    'Despacho de orden ' . $orden->numero_orden
                );
            }

            // Cambiar el estado únicamente después de procesar todo.
            $orden->update([
                'estado' => 'despachada',
                'fecha_despacho' => now(),
            ]);

            return $orden->load([
                'almacen',
                'detalles.producto',
            ]);

        }, 3);

        return response()->json([
            'mensaje' => 'Orden despachada correctamente.',
            'datos' => $orden,
        ]);
    }

    // Cancelar una orden que todavía no ha sido despachada.
    public function cancelar(
        OrdenDespacho $ordenDespacho
    ): JsonResponse {

        $orden = DB::transaction(function () use ($ordenDespacho) {

            // Bloquear la orden para evitar cambios simultáneos.
            $orden = OrdenDespacho::query()
                ->lockForUpdate()
                ->findOrFail($ordenDespacho->id);

            // Solo las órdenes pendientes pueden cancelarse.
            if ($orden->estado !== 'pendiente') {
                throw ValidationException::withMessages([
                    'estado' => [
                        'Solo se pueden cancelar órdenes pendientes.',
                    ],
                ]);
            }

            // Cambiar el estado sin modificar existencias.
            $orden->update([
                'estado' => 'cancelada',
            ]);

            return $orden->load([
                'almacen',
                'detalles.producto',
            ]);

        }, 3);

        return response()->json([
            'mensaje' => 'Orden cancelada correctamente.',
            'datos' => $orden,
        ]);
    }

}