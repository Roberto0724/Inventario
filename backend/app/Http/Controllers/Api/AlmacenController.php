<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Almacen;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AlmacenController extends Controller
{
    // Consultar almacenes activos y disponibles.
    public function index(): JsonResponse
    {
        return response()->json(
            Almacen::orderBy('nombre')->get()
        );
    }

    // Registrar un almacén.
    public function store(Request $request): JsonResponse
    {
        $datos = $request->validate([
            'nombre' => ['required', 'string', 'max:150'],
            'codigo' => ['required', 'string', 'max:50', 'unique:almacenes,codigo'],
            'ubicacion' => ['nullable', 'string', 'max:255'],
            'descripcion' => ['nullable', 'string'],
            'activo' => ['sometimes', 'boolean'],
        ]);

        $almacen = Almacen::create($datos);

        return response()->json([
            'mensaje' => 'Almacén registrado correctamente.',
            'almacen' => $almacen,
        ], 201);
    }

    // Consultar un almacén.
    public function show(Almacen $almacen): JsonResponse
    {
        return response()->json($almacen);
    }

    // Actualizar un almacén.
    public function update(Request $request, Almacen $almacen): JsonResponse
    {
        $datos = $request->validate([
            'nombre' => ['required', 'string', 'max:150'],
            'codigo' => [
                'required',
                'string',
                'max:50',
                Rule::unique('almacenes', 'codigo')->ignore($almacen->id),
            ],
            'ubicacion' => ['nullable', 'string', 'max:255'],
            'descripcion' => ['nullable', 'string'],
            'activo' => ['sometimes', 'boolean'],
        ]);

        $almacen->update($datos);

        return response()->json([
            'mensaje' => 'Almacén actualizado correctamente.',
            'almacen' => $almacen->fresh(),
        ]);
    }

    // Enviar un almacén a la papelera.
    public function destroy(Almacen $almacen): JsonResponse
    {
        $almacen->delete();

        return response()->json([
            'mensaje' => 'Almacén enviado a la papelera correctamente.',
        ]);
    }


public function papelera(): JsonResponse
{
    $almacenes = Almacen::onlyTrashed()
        ->orderByDesc('deleted_at')
        ->get();

    return response()->json($almacenes);
}

public function restaurar(int $id): JsonResponse
{
    $almacen = Almacen::onlyTrashed()->findOrFail($id);

    $almacen->restore();

    return response()->json([
        'mensaje' => 'Almacén restaurado correctamente',
        'almacen' => $almacen,
    ]);
}

}
