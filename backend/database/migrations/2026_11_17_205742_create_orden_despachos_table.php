<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ordenes_despacho', function (Blueprint $table) {
            $table->id();

            $table->string('numero_orden', 30)->unique();

            $table->foreignId('almacen_id')
                ->constrained('almacenes')
                ->restrictOnDelete();

            $table->string('destinatario', 150);
            $table->string('direccion_destino', 255);

            $table->string('estado', 20)->default('pendiente');

            $table->text('observacion')->nullable();

            $table->timestamp('fecha_despacho')->nullable();

            $table->timestamps();

            $table->index('estado');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ordenes_despacho');
    }
};
