
class MovimientoInventario {
  final int id;
  final int productoId;
  final String nombreProducto;
  final String skuProducto;
  final String tipo;
  final int cantidad;
  final String? almacenOrigen;
  final String? almacenDestino;
  final String? referencia;
  final String? observacion;
  final DateTime? fecha;

  MovimientoInventario({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.skuProducto,
    required this.tipo,
    required this.cantidad,
    this.almacenOrigen,
    this.almacenDestino,
    this.referencia,
    this.observacion,
    this.fecha,
  });

  factory MovimientoInventario.desdeJson(
    Map<String, dynamic> json,
  ) {
    final producto =
        json['producto'] as Map<String, dynamic>? ?? {};

    final origen =
        json['almacen_origen'] as Map<String, dynamic>?;

    final destino =
        json['almacen_destino'] as Map<String, dynamic>?;

    return MovimientoInventario(
      id: int.parse(json['id'].toString()),
      productoId: int.parse(json['producto_id'].toString()),
      nombreProducto: producto['nombre']?.toString() ?? '',
      skuProducto: producto['sku']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      cantidad: int.parse(json['cantidad'].toString()),
      almacenOrigen: origen?['nombre']?.toString(),
      almacenDestino: destino?['nombre']?.toString(),
      referencia: json['referencia']?.toString(),
      observacion: json['observacion']?.toString(),
      fecha: DateTime.tryParse(
        json['created_at']?.toString() ?? '',
      ),
    );
  }
}
