<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MovimientoInventario extends Model
{
    protected $table = 'movimientos_inventario';

    protected $fillable = [
        'producto_id',
        'almacen_origen_id',
        'almacen_destino_id',
        'tipo',
        'cantidad',
        'referencia',
        'observacion',
    ];

    protected $casts = [
        'cantidad' => 'integer',
    ];

    public function producto(): BelongsTo
    {
        return $this->belongsTo(Producto::class);
    }

    public function almacenOrigen(): BelongsTo
    {
        return $this->belongsTo(
            Almacen::class,
            'almacen_origen_id'
        );
    }

    public function almacenDestino(): BelongsTo
    {
        return $this->belongsTo(
            Almacen::class,
            'almacen_destino_id'
        );
    }
}
