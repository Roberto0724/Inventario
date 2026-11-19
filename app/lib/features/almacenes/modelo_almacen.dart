class Almacen {
  final String id;
  final String nombre;
  final String codigo;
  final String ubicacion;
  final String descripcion;
  final bool activo;

  const Almacen({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.ubicacion,
    required this.descripcion,
    required this.activo,
  });

  factory Almacen.desdeJson(Map<String, dynamic> datos) {
    return Almacen(
      id: datos['id']?.toString() ?? '',
      nombre: datos['nombre']?.toString() ?? '',
      codigo: datos['codigo']?.toString() ?? '',
      ubicacion: datos['ubicacion']?.toString() ?? '',
      descripcion: datos['descripcion']?.toString() ?? '',
      activo:
          datos['activo'] == true ||
          datos['activo'] == 1 ||
          datos['activo'] == '1',
    );
  }

  Map<String, dynamic> aJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'ubicacion': ubicacion,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  Almacen copiarCon({
    String? id,
    String? nombre,
    String? codigo,
    String? ubicacion,
    String? descripcion,
    bool? activo,
  }) {
    return Almacen(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      ubicacion: ubicacion ?? this.ubicacion,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }
}
