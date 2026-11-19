<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ExistenciaAlmacen;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExistenciaAlmacenController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $datos = $request->validate([
            'producto_id' => ['nullable', 'integer', 'exists:productos,id'],
            'almacen_id' => ['nullable', 'integer', 'exists:almacenes,id'],
        ]);

        $consulta = ExistenciaAlmacen::query()
            ->with([
                'producto:id,nombre,sku',
                'almacen:id,nombre,codigo',
            ]);

        if (isset($datos['producto_id'])) {
            $consulta->where('producto_id', $datos['producto_id']);
        }

        if (isset($datos['almacen_id'])) {
            $consulta->where('almacen_id', $datos['almacen_id']);
        }

        $existencias = $consulta
            ->orderBy('almacen_id')
            ->orderBy('producto_id')
            ->get();

        return response()->json($existencias);
    }
}
