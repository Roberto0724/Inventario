import 'dart:convert';

import 'package:http/http.dart' as http;

import 'modelo_almacen.dart';

class ServicioAlmacenes {
  final String urlBase = 'http://127.0.0.1:8000/api';

  // Consultar todos los almacenes.
  Future<List<Almacen>> obtenerAlmacenes() async {
    final respuesta = await http.get(
      Uri.parse('$urlBase/almacenes'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudieron consultar los almacenes: ${respuesta.body}',
      );
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map((dato) => Almacen.desdeJson(dato as Map<String, dynamic>))
        .toList();
  }

  // Registrar un nuevo almacén.
  Future<void> registrarAlmacen(Almacen almacen) async {
    final respuesta = await http.post(
      Uri.parse('$urlBase/almacenes'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(almacen.aJson()),
    );

    if (respuesta.statusCode != 201) {
      throw Exception('No se pudo registrar el almacén: ${respuesta.body}');
    }
  }

  // Actualizar un almacén existente.
  Future<void> actualizarAlmacen(Almacen almacen) async {
    final respuesta = await http.put(
      Uri.parse('$urlBase/almacenes/${almacen.id}'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(almacen.aJson()),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo actualizar el almacén: ${respuesta.body}');
    }
  }

  // Enviar un almacén a la papelera.
  Future<void> eliminarAlmacen(String id) async {
    final respuesta = await http.delete(
      Uri.parse('$urlBase/almacenes/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo eliminar el almacén: ${respuesta.body}');
    }
  }

  Future<List<Almacen>> obtenerPapelera() async {
    final respuesta = await http.get(Uri.parse('$urlBase/almacenes/papelera'));

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo consultar la papelera de almacenes');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map((dato) => Almacen.desdeJson(dato as Map<String, dynamic>))
        .toList();
  }

  Future<void> restaurarAlmacen(String id) async {
    final respuesta = await http.patch(
      Uri.parse('$urlBase/almacenes/$id/restaurar'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo restaurar el almacén');
    }
  }
}
