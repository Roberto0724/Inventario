<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProductoController;
use App\Http\Controllers\Api\CategoriaController;
use App\Http\Controllers\Api\AlmacenController;
use App\Http\Controllers\Api\ExistenciaAlmacenController;
use App\Http\Controllers\Api\MovimientoInventarioController;
use App\Http\Controllers\Api\OrdenDespachoController;


// Consultar productos eliminados.
Route::get(
    'productos/papelera',
    [ProductoController::class, 'papelera']
);

// Restaurar un producto eliminado.
Route::patch(
    'productos/{id}/restaurar',
    [ProductoController::class, 'restaurar']
);

// Rutas de productos.
Route::apiResource('productos', ProductoController::class);


// Rutas de categorías.
Route::apiResource('categorias', CategoriaController::class);

// Ruta del usuario autenticado.
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::get('almacenes/papelera', [AlmacenController::class, 'papelera']);

Route::patch('almacenes/{id}/restaurar', [AlmacenController::class, 'restaurar']);

// Gestión de almacenes.
Route::apiResource('almacenes', AlmacenController::class)
    ->parameters(['almacenes' => 'almacen']);

    Route::get('existencias-almacen', [ExistenciaAlmacenController::class, 'index']);

    Route::get(
    'movimientos-inventario',
    [MovimientoInventarioController::class, 'index']
);

Route::post(
    'movimientos-inventario',
    [MovimientoInventarioController::class, 'store']
);

Route::post(
    'movimientos-inventario/salida',
    [MovimientoInventarioController::class, 'registrarSalida']
);

Route::post(
    'movimientos-inventario/transferencia',
    [MovimientoInventarioController::class, 'registrarTransferencia']
);

// Logística: órdenes de despacho
Route::get('ordenes-despacho', [OrdenDespachoController::class, 'index']);

Route::get('ordenes-despacho/{ordenDespacho}', [OrdenDespachoController::class, 'show']);

Route::post('ordenes-despacho', [OrdenDespachoController::class, 'store']);

// Confirmar el despacho de una orden pendiente.
Route::post('ordenes-despacho/{ordenDespacho}/confirmar', [OrdenDespachoController::class, 'confirmarDespacho']);

// Cancelar una orden de despacho pendiente.
Route::post(
    'ordenes-despacho/{ordenDespacho}/cancelar',
    [OrdenDespachoController::class, 'cancelar']
);