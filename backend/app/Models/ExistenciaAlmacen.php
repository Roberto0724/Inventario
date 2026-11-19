<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExistenciaAlmacen extends Model
{
    protected $table = 'existencias_almacen';

    protected $fillable = [
        'producto_id',
        'almacen_id',
        'cantidad',
    ];

    protected function casts(): array
    {
        return [
            'producto_id' => 'integer',
            'almacen_id' => 'integer',
            'cantidad' => 'integer',
        ];
    }

    public function producto(): BelongsTo
    {
        return $this->belongsTo(Producto::class, 'producto_id');
    }

    public function almacen(): BelongsTo
    {
        return $this->belongsTo(Almacen::class, 'almacen_id');
    }
}
