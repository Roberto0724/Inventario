<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Almacen extends Model
{
    use SoftDeletes;

    protected $table = 'almacenes';

    protected $fillable = [
        'nombre',
        'codigo',
        'ubicacion',
        'descripcion',
        'activo',
    ];

    protected function casts(): array
    {
        return [
            'activo' => 'boolean',
        ];
    }

public function existencias(): HasMany
{
    return $this->hasMany(
        ExistenciaAlmacen::class,
        'almacen_id'
    );
}

}
