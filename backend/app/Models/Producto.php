<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Producto extends Model
{
    use SoftDeletes;
    // Tabla de PostgreSQL asociada al modelo.
    protected $table = 'productos';

    // Campos permitidos para registrar y actualizar productos.
    protected $fillable = [
        'nombre',
        'sku',
        'codigo_barras',
        'categoria',
        'precio',
        'existencia',
        'existencia_minima',
    ];

    // Conversión automática de tipos de datos.
    protected function casts(): array
    {
        return [
            'precio' => 'decimal:2',
            'existencia' => 'integer',
            'existencia_minima' => 'integer',
        ];
    }

    // Determina si el producto tiene existencia baja.
    public function tieneExistenciaBaja(): bool
    {
        return $this->existencia <= $this->existencia_minima;
    }

public function existenciasPorAlmacen(): HasMany
{
    return $this->hasMany(
        ExistenciaAlmacen::class,
        'producto_id'
    );
}

}
