<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('movimientos_inventario', function (Blueprint $table) {
            $table->id();

            $table->foreignId('producto_id')
                ->constrained('productos')
                ->restrictOnDelete();

            $table->foreignId('almacen_origen_id')
                ->nullable()
                ->constrained('almacenes')
                ->restrictOnDelete();

            $table->foreignId('almacen_destino_id')
                ->nullable()
                ->constrained('almacenes')
                ->restrictOnDelete();

            $table->string('tipo', 20);
            $table->unsignedInteger('cantidad');
            $table->string('referencia')->nullable();
            $table->text('observacion')->nullable();

            $table->timestamps();

            $table->index(['producto_id', 'created_at']);
            $table->index(['tipo', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('movimientos_inventario');
    }
};
