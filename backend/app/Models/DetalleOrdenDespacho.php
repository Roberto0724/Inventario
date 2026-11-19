<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DetalleOrdenDespacho extends Model
{
    protected $table = 'detalles_orden_despacho';

    protected $fillable = [
        'orden_despacho_id',
        'producto_id',
        'cantidad',
    ];

    protected $casts = [
        'cantidad' => 'integer',
    ];

    // Orden de despacho a la que pertenece el detalle.
    public function ordenDespacho(): BelongsTo
    {
        return $this->belongsTo(
            OrdenDespacho::class,
            'orden_despacho_id'
        );
    }

    // Producto asociado al detalle.
    public function producto(): BelongsTo
    {
        return $this->belongsTo(
            Producto::class,
            'producto_id'
        );
    }
}
