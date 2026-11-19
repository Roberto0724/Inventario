<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Categoria;
use Illuminate\Validation\Rule;
use Illuminate\Http\Request;

class CategoriaController extends Controller
{
    /**
     * Display a listing of the resource.
     */

public function index()
{
    // Consultar las categorías ordenadas por nombre.
    $categorias = Categoria::orderBy('nombre')->get();

    // Devolver las categorías en formato JSON.
    return response()->json($categorias);
}


    /**
     * Store a newly created resource in storage.
     */

public function store(Request $solicitud)
{
    // Validar la información recibida.
    $datos = $solicitud->validate([
        'nombre' => ['required', 'string', 'max:150', 'unique:categorias,nombre'],
        'descripcion' => ['nullable', 'string'],
        'activo' => ['sometimes', 'boolean'],
    ]);

    // Registrar la categoría en PostgreSQL.
    $categoria = Categoria::create($datos);

    // Devolver la categoría registrada.
    return response()->json($categoria, 201);
}


    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */

public function update(Request $solicitud, string $id)
{
    // Buscar la categoría que se desea actualizar.
    $categoria = Categoria::findOrFail($id);

    // Validar los datos recibidos.
    $datos = $solicitud->validate([
        'nombre' => [
            'sometimes',
            'required',
            'string',
            'max:150',
            Rule::unique('categorias', 'nombre')->ignore($categoria->id),
        ],
        'descripcion' => ['sometimes', 'nullable', 'string'],
        'activo' => ['sometimes', 'boolean'],
    ]);

    // Actualizar la categoría.
    $categoria->update($datos);

    // Devolver los datos actualizados.
    return response()->json($categoria->fresh(), 200);
}


    /**
     * Remove the specified resource from storage.
     */

public function destroy(string $id)
{
    $categoria = Categoria::findOrFail($id);

    // Verificar si existen productos asociados a esta categoría.
    $tieneProductos = \App\Models\Producto::where(
        'categoria',
        $categoria->nombre
    )->exists();

    if ($tieneProductos) {
        return response()->json([
            'mensaje' => 'No se puede eliminar esta categoría porque tiene productos asociados.',
        ], 409);
    }

    $categoria->delete();

    return response()->json([
        'mensaje' => 'Categoría eliminada correctamente.',
    ], 200);
}

}
