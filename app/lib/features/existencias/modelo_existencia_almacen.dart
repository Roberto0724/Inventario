class ExistenciaAlmacen {
  final String id;
  final String productoId;
  final String almacenId;
  final int cantidad;

  final String nombreProducto;
  final String skuProducto;
  final String nombreAlmacen;
  final String codigoAlmacen;

  const ExistenciaAlmacen({
    required this.id,
    required this.productoId,
    required this.almacenId,
    required this.cantidad,
    required this.nombreProducto,
    required this.skuProducto,
    required this.nombreAlmacen,
    required this.codigoAlmacen,
  });

  factory ExistenciaAlmacen.desdeJson(Map<String, dynamic> json) {
    final producto = json['producto'] as Map<String, dynamic>?;
    final almacen = json['almacen'] as Map<String, dynamic>?;

    return ExistenciaAlmacen(
      id: json['id'].toString(),
      productoId: json['producto_id'].toString(),
      almacenId: json['almacen_id'].toString(),
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 0,
      nombreProducto: producto?['nombre']?.toString() ?? '',
      skuProducto: producto?['sku']?.toString() ?? '',
      nombreAlmacen: almacen?['nombre']?.toString() ?? '',
      codigoAlmacen: almacen?['codigo']?.toString() ?? '',
    );
  }
}
