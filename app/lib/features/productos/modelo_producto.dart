class Producto {
  final String id;
  final String nombre;
  final String sku;
  final String codigoBarras;
  final String categoria;
  final double precio;
  final int existencia;
  final int existenciaMinima;

  const Producto({
    required this.id,
    required this.nombre,
    required this.sku,
    required this.codigoBarras,
    required this.categoria,
    required this.precio,
    required this.existencia,
    required this.existenciaMinima,
  });

  bool get tieneExistenciaBaja => existencia <= existenciaMinima;

  factory Producto.desdeJson(Map<String, dynamic> datos) {
    return Producto(
      id: datos['id'].toString(),
      nombre: datos['nombre']?.toString() ?? '',
      sku: datos['sku']?.toString() ?? '',
      codigoBarras: datos['codigo_barras']?.toString() ?? '',
      categoria: datos['categoria']?.toString() ?? '',
      precio: double.tryParse(datos['precio'].toString()) ?? 0,
      existencia: int.tryParse(datos['existencia'].toString()) ?? 0,
      existenciaMinima:
          int.tryParse(datos['existencia_minima'].toString()) ?? 0,
    );
  }

  Producto copiarCon({
    String? id,
    String? nombre,
    String? sku,
    String? codigoBarras,
    String? categoria,
    double? precio,
    int? existencia,
    int? existenciaMinima,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      sku: sku ?? this.sku,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      existencia: existencia ?? this.existencia,
      existenciaMinima: existenciaMinima ?? this.existenciaMinima,
    );
  }
}
