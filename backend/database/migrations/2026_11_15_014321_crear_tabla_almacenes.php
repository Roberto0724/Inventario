<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('almacenes', function (Blueprint $tabla) {
            $tabla->id();
            $tabla->string('nombre', 150);
            $tabla->string('codigo', 50)->unique();
            $tabla->string('ubicacion', 255)->nullable();
            $tabla->text('descripcion')->nullable();
            $tabla->boolean('activo')->default(true);
            $tabla->timestamps();
            $tabla->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('almacenes');
    }
};
