<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('detalles_orden_despacho', function (Blueprint $table) {
            $table->id();

            // Orden a la que pertenece el detalle.
            $table->foreignId('orden_despacho_id')
                ->constrained('ordenes_despacho')
                ->cascadeOnDelete();

            // Producto incluido en la orden.
            $table->foreignId('producto_id')
                ->constrained('productos')
                ->restrictOnDelete();

            // Cantidad solicitada para el despacho.
            $table->unsignedInteger('cantidad');

            $table->timestamps();

            // Evita repetir un producto dentro de la misma orden.
            $table->unique([
                'orden_despacho_id',
                'producto_id',
            ]);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('detalles_orden_despacho');
    }
};
