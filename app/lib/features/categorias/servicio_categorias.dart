import 'dart:convert';

import 'package:http/http.dart' as http;

import 'modelo_categoria.dart';

class ServicioCategorias {
  static const String urlBase = 'http://127.0.0.1:8000/api';

  // Consultar las categorías registradas en Laravel.
  Future<List<Categoria>> obtenerCategorias() async {
    final respuesta = await http.get(
      Uri.parse('$urlBase/categorias'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudieron obtener las categorías. '
        'Código: ${respuesta.statusCode}',
      );
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map((dato) => Categoria.desdeJson(Map<String, dynamic>.from(dato)))
        .toList();
  }

  // Registrar una nueva categoría.
  Future<void> registrarCategoria(Categoria categoria) async {
    final respuesta = await http.post(
      Uri.parse('$urlBase/categorias'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(categoria.convertirAJson()),
    );

    if (respuesta.statusCode != 201) {
      throw Exception(
        'No se pudo registrar la categoría. '
        'Código: ${respuesta.statusCode}. '
        '${respuesta.body}',
      );
    }
  }

  // Actualizar una categoría existente en Laravel.
  Future<void> actualizarCategoria(Categoria categoria) async {
    final respuesta = await http.put(
      Uri.parse('$urlBase/categorias/${categoria.id}'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(categoria.convertirAJson()),
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudo actualizar la categoría. '
        'Código: ${respuesta.statusCode}. '
        '${respuesta.body}',
      );
    }
  }

  // Eliminar una categoría desde Laravel.
  Future<void> eliminarCategoria(String id) async {
    final respuesta = await http.delete(
      Uri.parse('$urlBase/categorias/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode == 200) {
      return;
    }

    if (respuesta.statusCode == 409) {
      throw Exception(
        'No se puede eliminar la categoría porque tiene productos asociados.',
      );
    }

    throw Exception(
      'No se pudo eliminar la categoría. '
      'Código: ${respuesta.statusCode}. '
      '${respuesta.body}',
    );
  }
}
