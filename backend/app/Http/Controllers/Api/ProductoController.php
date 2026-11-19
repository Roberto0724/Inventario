<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Producto;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProductoController extends Controller
{
    // Consultar todos los productos.
    public function index(): JsonResponse
    {
        $productos = Producto::orderBy('id', 'desc')->get();

        return response()->json($productos);
    }

    // Registrar un nuevo producto.
    public function store(Request $request): JsonResponse
    {
        $datos = $request->validate([
            'nombre' => ['required', 'string', 'max:150'],
            'sku' => ['required', 'string', 'max:100', 'unique:productos,sku'],
            'codigo_barras' => ['nullable', 'string', 'max:100', 'unique:productos,codigo_barras'],
            'categoria' => ['required', 'string', 'max:100'],
            'precio' => ['required', 'numeric', 'min:0'],
            'existencia' => ['required', 'integer', 'min:0'],
            'existencia_minima' => ['required', 'integer', 'min:0'],
        ]);

        $producto = Producto::create($datos);

        return response()->json([
            'mensaje' => 'Producto registrado correctamente.',
            'producto' => $producto,
        ], 201);
    }

    // Consultar un producto por su identificador.
    public function show(Producto $producto): JsonResponse
    {
        return response()->json($producto);
    }

    // Actualizar un producto existente.
    public function update(Request $request, Producto $producto): JsonResponse
    {
        $datos = $request->validate([
            'nombre' => ['required', 'string', 'max:150'],
            'sku' => [
                'required',
                'string',
                'max:100',
                Rule::unique('productos', 'sku')->ignore($producto->id),
            ],
            'codigo_barras' => [
                'nullable',
                'string',
                'max:100',
                Rule::unique('productos', 'codigo_barras')->ignore($producto->id),
            ],
            'categoria' => ['required', 'string', 'max:100'],
            'precio' => ['required', 'numeric', 'min:0'],
            'existencia' => ['required', 'integer', 'min:0'],
            'existencia_minima' => ['required', 'integer', 'min:0'],
        ]);

        $producto->update($datos);

        return response()->json([
            'mensaje' => 'Producto actualizado correctamente.',
            'producto' => $producto->fresh(),
        ]);
    }

    // Eliminar un producto.
    public function destroy(Producto $producto): JsonResponse
    {
        $producto->delete();

        return response()->json([
            'mensaje' => 'Producto eliminado correctamente.',
        ]);
    }

/**
 * Restaurar un producto eliminado.
 */
public function restaurar(string $id)
{
    // Buscar únicamente productos eliminados.
    $producto = Producto::onlyTrashed()->find($id);

    if (!$producto) {
        return response()->json([
            'mensaje' => 'El producto no existe en la papelera.',
        ], 404);
    }

    // Restaurar el producto sin perder sus datos.
    $producto->restore();

    return response()->json([
        'mensaje' => 'Producto restaurado correctamente.',
        'producto' => $producto->fresh(),
    ], 200);
}


/**
 * Obtener los productos eliminados.
 */
public function papelera()
{
    $productos = Producto::onlyTrashed()
        ->orderByDesc('deleted_at')
        ->get();

    return response()->json($productos, 200);
}

}
