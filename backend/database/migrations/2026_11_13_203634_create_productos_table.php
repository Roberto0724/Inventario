
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Crear la tabla de productos del inventario.
     */
    public function up(): void
    {
        Schema::create('productos', function (Blueprint $tabla) {
            $tabla->id();

            $tabla->string('nombre', 150);
            $tabla->string('sku', 100)->unique();
            $tabla->string('codigo_barras', 100)->nullable()->unique();
            $tabla->string('categoria', 100);

            $tabla->decimal('precio', 12, 2)->default(0);
            $tabla->integer('existencia')->default(0);
            $tabla->integer('existencia_minima')->default(0);

            $tabla->timestamps();
        });
    }

    /**
     * Eliminar la tabla si se revierte la migración.
     */
    public function down(): void
    {
        Schema::dropIfExists('productos');
    }
};
