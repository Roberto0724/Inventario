class Categoria {
  final String id;
  final String nombre;
  final String descripcion;
  final bool activo;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  factory Categoria.desdeJson(Map<String, dynamic> datos) {
    return Categoria(
      id: datos['id'].toString(),
      nombre: datos['nombre'].toString(),
      descripcion: datos['descripcion']?.toString() ?? '',
      activo: datos['activo'] == true,
    );
  }

  Map<String, dynamic> convertirAJson() {
    return {'nombre': nombre, 'descripcion': descripcion, 'activo': activo};
  }
}
