<?php

namespace App\Http\Controllers\Api {
    use App\Http\Controllers\Controller;
    use App\Models\MovimientoInventario;
    use Illuminate\Http\JsonResponse;
    use Illuminate\Http\Request;
    use Illuminate\Validation\Rule;
    use App\Models\Producto;
    use App\Models\Almacen;
    use App\Models\ExistenciaAlmacen;
    use Illuminate\Support\Facades\DB;

    class MovimientoInventarioController extends Controller
    {
        public function index(Request $request): JsonResponse
        {
            $filtros = $request->validate([
                'producto_id' => ['sometimes', 'integer', 'exists:productos,id'],
                'tipo' => [
                    'sometimes',
                    Rule::in(['entrada', 'salida', 'transferencia']),
                ],
            ]);

            $movimientos = MovimientoInventario::query()
                ->with([
                    'producto:id,nombre,sku',
                    'almacenOrigen:id,nombre,codigo',
                    'almacenDestino:id,nombre,codigo',
                ])
                ->when(
                    isset($filtros['producto_id']),
                    fn ($consulta) => $consulta->where(
                        'producto_id',
                        $filtros['producto_id']
                    )
                )
                ->when(
                    isset($filtros['tipo']),
                    fn ($consulta) => $consulta->where(
                        'tipo',
                        $filtros['tipo']
                    )
                )
                ->orderByDesc('id')
                ->paginate(20);

            return response()->json($movimientos);
        }

        public function store(Request $request): JsonResponse
        {
            $datos = $request->validate([
                'producto_id' => ['required', 'integer', 'exists:productos,id'],
                'almacen_destino_id' => ['required', 'integer', 'exists:almacenes,id'],
                'cantidad' => ['required', 'integer', 'min:1'],
                'referencia' => ['nullable', 'string', 'max:255'],
                'observacion' => ['nullable', 'string'],
            ]);

            $resultado = DB::transaction(function () use ($datos) {

                // Bloquear el producto para serializar sus movimientos.
                $producto = Producto::query()
                    ->lockForUpdate()
                    ->findOrFail($datos['producto_id']);

                $almacen = Almacen::query()
                    ->where('activo', true)
                    ->findOrFail($datos['almacen_destino_id']);

                // Crear el registro si aún no existe.
                // El bloqueo del producto coordina las operaciones
                // realizadas mediante este controlador.
                $existencia = ExistenciaAlmacen::query()
                    ->firstOrCreate(
                        [
                            'producto_id' => $producto->id,
                            'almacen_id' => $almacen->id,
                        ],
                        ['cantidad' => 0]
                    );

                $existencia->increment('cantidad', $datos['cantidad']);

                // Mantener sincronizado el total general del producto.
                // No sumamos nuevamente las existencias existentes.
                $producto->increment('existencia', $datos['cantidad']);

                $movimiento = MovimientoInventario::create([
                    'producto_id' => $producto->id,
                    'almacen_origen_id' => null,
                    'almacen_destino_id' => $almacen->id,
                    'tipo' => 'entrada',
                    'cantidad' => $datos['cantidad'],
                    'referencia' => $datos['referencia'] ?? null,
                    'observacion' => $datos['observacion'] ?? null,
                ]);

                return [
                    'movimiento' => $movimiento->load([
                        'producto:id,nombre,sku',
                        'almacenDestino:id,nombre,codigo',
                    ]),
                    'existencia_almacen' => $existencia->fresh(),
                    'existencia_total' => $producto->fresh()->existencia,
                ];
            }, 3);

            return response()->json([
                'mensaje' => 'Entrada de inventario registrada correctamente.',
                'datos' => $resultado,
            ], 201);
        }

        public function registrarSalida(Request $request): JsonResponse
        {
            $datos = $request->validate([
                'producto_id' => ['required', 'integer', 'exists:productos,id'],
                'almacen_origen_id' => ['required', 'integer', 'exists:almacenes,id'],
                'cantidad' => ['required', 'integer', 'min:1'],
                'referencia' => ['nullable', 'string', 'max:255'],
                'observacion' => ['nullable', 'string'],
            ]);

            $resultado = DB::transaction(function () use ($datos) {
                $producto = Producto::query()
                    ->lockForUpdate()
                    ->findOrFail($datos['producto_id']);

                $almacen = Almacen::query()
                    ->where('activo', true)
                    ->findOrFail($datos['almacen_origen_id']);

                $existencia = ExistenciaAlmacen::query()
                    ->where('producto_id', $producto->id)
                    ->where('almacen_id', $almacen->id)
                    ->lockForUpdate()
                    ->first();

                if (!$existencia || $existencia->cantidad < $datos['cantidad']) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        'cantidad' => ['No hay suficientes unidades disponibles en este almacén.'],
                    ]);
                }

                if ($producto->existencia < $datos['cantidad']) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        'cantidad' => ['La existencia general del producto es insuficiente.'],
                    ]);
                }

                $existencia->decrement('cantidad', $datos['cantidad']);
                $producto->decrement('existencia', $datos['cantidad']);

                $movimiento = MovimientoInventario::create([
                    'producto_id' => $producto->id,
                    'almacen_origen_id' => $almacen->id,
                    'almacen_destino_id' => null,
                    'tipo' => 'salida',
                    'cantidad' => $datos['cantidad'],
                    'referencia' => $datos['referencia'] ?? null,
                    'observacion' => $datos['observacion'] ?? null,
                ]);

                return [
                    'movimiento' => $movimiento->load([
                        'producto:id,nombre,sku',
                        'almacenOrigen:id,nombre,codigo',
                    ]),
                    'existencia_almacen' => $existencia->fresh(),
                    'existencia_total' => $producto->fresh()->existencia,
                ];
            }, 3);

            return response()->json([
                'mensaje' => 'Salida de inventario registrada correctamente.',
                'datos' => $resultado,
            ], 201);
        }

        public function registrarTransferencia(Request $request): JsonResponse
        {
            $datos = $request->validate([
                'producto_id' => ['required', 'integer', 'exists:productos,id'],
                'almacen_origen_id' => ['required', 'integer', 'exists:almacenes,id'],
                'almacen_destino_id' => [
                    'required',
                    'integer',
                    'exists:almacenes,id',
                    'different:almacen_origen_id',
                ],
                'cantidad' => ['required', 'integer', 'min:1'],
                'referencia' => ['nullable', 'string', 'max:255'],
                'observacion' => ['nullable', 'string'],
            ]);

            $resultado = DB::transaction(function () use ($datos) {
                // Bloqueamos el producto para coordinar sus movimientos.
                $producto = Producto::query()
                    ->lockForUpdate()
                    ->findOrFail($datos['producto_id']);

                $almacenes = Almacen::query()
                    ->whereIn('id', [
                        $datos['almacen_origen_id'],
                        $datos['almacen_destino_id'],
                    ])
                    ->where('activo', true)
                    ->orderBy('id')
                    ->lockForUpdate()
                    ->get()
                    ->keyBy('id');

                if (
                    !$almacenes->has($datos['almacen_origen_id']) ||
                    !$almacenes->has($datos['almacen_destino_id'])
                ) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        'almacen_destino_id' => [
                            'Los almacenes deben existir y estar activos.',
                        ],
                    ]);
                }

                $origen = ExistenciaAlmacen::query()
                    ->where('producto_id', $producto->id)
                    ->where('almacen_id', $datos['almacen_origen_id'])
                    ->lockForUpdate()
                    ->first();

                if (!$origen || $origen->cantidad < $datos['cantidad']) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        'cantidad' => [
                            'No hay suficientes unidades en el almacén de origen.',
                        ],
                    ]);
                }

                $destino = ExistenciaAlmacen::query()
                    ->firstOrCreate(
                        [
                            'producto_id' => $producto->id,
                            'almacen_id' => $datos['almacen_destino_id'],
                        ],
                        ['cantidad' => 0]
                    );

                $origen->decrement('cantidad', $datos['cantidad']);
                $destino->increment('cantidad', $datos['cantidad']);

                $movimiento = MovimientoInventario::create([
                    'producto_id' => $producto->id,
                    'almacen_origen_id' => $datos['almacen_origen_id'],
                    'almacen_destino_id' => $datos['almacen_destino_id'],
                    'tipo' => 'transferencia',
                    'cantidad' => $datos['cantidad'],
                    'referencia' => $datos['referencia'] ?? null,
                    'observacion' => $datos['observacion'] ?? null,
                ]);

                return [
                    'movimiento' => $movimiento->load([
                        'producto:id,nombre,sku',
                        'almacenOrigen:id,nombre,codigo',
                        'almacenDestino:id,nombre,codigo',
                    ]),
                    'existencia_origen' => $origen->fresh(),
                    'existencia_destino' => $destino->fresh(),
                    'existencia_total' => $producto->fresh()->existencia,
                ];
            }, 3);

            return response()->json([
                'mensaje' => 'Transferencia de inventario registrada correctamente.',
                'datos' => $resultado,
            ], 201);
        }
    }
}
