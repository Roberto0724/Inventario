<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class OrdenDespacho extends Model
{
    protected $table = 'ordenes_despacho';

    protected $fillable = [
        'numero_orden',
        'almacen_id',
        'destinatario',
        'direccion_destino',
        'estado',
        'observacion',
        'fecha_despacho',
    ];

    protected $casts = [
        'fecha_despacho' => 'datetime',
    ];

    public function almacen(): BelongsTo
    {
        return $this->belongsTo(Almacen::class);
    }

    public function detalles(): HasMany
    {
        return $this->hasMany(
            DetalleOrdenDespacho::class,
            'orden_despacho_id'
        );
    }
}
