<?php

namespace App\Services;

use App\Models\Producto;
use App\Models\Almacen;
use App\Models\ExistenciaAlmacen;
use App\Models\MovimientoInventario;
use Illuminate\Validation\ValidationException;

class ServicioSalidaInventario
{
    /**
     * Registra una salida de inventario.
     *
     * Debe ejecutarse dentro de una transacción DB::transaction().
     * Los productos deben bloquearse en orden ascendente de ID
     * cuando se procesen varias salidas.
     */
    public function registrarSalida(
        int $productoId,
        int $almacenId,
        int $cantidad,
        ?string $referencia = null,
        ?string $observacion = null
    ): MovimientoInventario {

        if ($cantidad < 1) {
            throw ValidationException::withMessages([
                'cantidad' => ['La cantidad debe ser mayor que cero.'],
            ]);
        }

        // Bloquear el producto para evitar descuentos simultáneos.
        $producto = Producto::query()
            ->lockForUpdate()
            ->findOrFail($productoId);

        // Verificar que el almacén esté activo.
        $almacen = Almacen::query()
            ->where('activo', true)
            ->findOrFail($almacenId);

        // Bloquear la existencia del producto en el almacén.
        $existencia = ExistenciaAlmacen::query()
            ->where('producto_id', $productoId)
            ->where('almacen_id', $almacenId)
            ->lockForUpdate()
            ->first();

        if (!$existencia || $existencia->cantidad < $cantidad) {
            throw ValidationException::withMessages([
                'cantidad' => [
                    'No hay suficientes unidades disponibles en este almacén.',
                ],
            ]);
        }

        if ($producto->existencia < $cantidad) {
            throw ValidationException::withMessages([
                'cantidad' => [
                    'La existencia general del producto es insuficiente.',
                ],
            ]);
        }

        // Descontar las cantidades correspondientes.
        $existencia->decrement('cantidad', $cantidad);
        $producto->decrement('existencia', $cantidad);

        // Registrar el movimiento para mantener la trazabilidad.
        return MovimientoInventario::create([
            'producto_id' => $productoId,
            'almacen_origen_id' => $almacenId,
            'almacen_destino_id' => null,
            'tipo' => 'salida',
            'cantidad' => $cantidad,
            'referencia' => $referencia,
            'observacion' => $observacion,
        ]);
    }
}
