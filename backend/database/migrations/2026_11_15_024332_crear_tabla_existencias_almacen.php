<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('existencias_almacen', function (Blueprint $table) {
            $table->id();

            $table->foreignId('producto_id')
                ->constrained('productos')
                ->restrictOnDelete();

            $table->foreignId('almacen_id')
                ->constrained('almacenes')
                ->restrictOnDelete();

            $table->unsignedInteger('cantidad')->default(0);

            $table->timestamps();

            $table->unique(
                ['producto_id', 'almacen_id'],
                'existencias_producto_almacen_unique'
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('existencias_almacen');
    }
};
