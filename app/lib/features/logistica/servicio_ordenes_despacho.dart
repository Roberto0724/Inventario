import 'dart:convert';

import 'package:http/http.dart' as http;

class ServicioOrdenesDespacho {
  static const String urlBase = 'http://127.0.0.1:8000/api';

  // Consultar las órdenes de despacho.
  Future<List<dynamic>> obtenerOrdenes() async {
    final respuesta = await http.get(
      Uri.parse('$urlBase/ordenes-despacho'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);
      return List<dynamic>.from(datos['data']);
    }

    throw Exception('Error al consultar las órdenes de despacho.');
  }

  // Consultar el detalle de una orden.
  Future<Map<String, dynamic>> obtenerOrden(int id) async {
    final respuesta = await http.get(
      Uri.parse('$urlBase/ordenes-despacho/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(respuesta.body),
      );
    }

    throw Exception('Error al consultar la orden.');
  }

  // Confirmar un despacho.
  Future<Map<String, dynamic>> confirmarDespacho(int id) async {
    final respuesta = await http.post(
      Uri.parse('$urlBase/ordenes-despacho/$id/confirmar'),
      headers: {'Accept': 'application/json'},
    );

    final datos = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 200) {
      return Map<String, dynamic>.from(datos);
    }

    throw Exception(
      datos['message'] ?? 'No se pudo confirmar el despacho.',
    );
  }

  // Cancelar una orden pendiente.
  Future<Map<String, dynamic>> cancelarOrden(int id) async {
    final respuesta = await http.post(
      Uri.parse('$urlBase/ordenes-despacho/$id/cancelar'),
      headers: {'Accept': 'application/json'},
    );

    final datos = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 200) {
      return Map<String, dynamic>.from(datos);
    }

    throw Exception(
      datos['message'] ?? 'No se pudo cancelar la orden.',
    );
  }

  // Crear una nueva orden de despacho.
  Future<Map<String, dynamic>> crearOrden({
    required int almacenId,
    required String destinatario,
    required String direccionDestino,
    String? observacion,
    required List<Map<String, dynamic>> productos,
  }) async {
    final datos = {
      'almacen_id': almacenId,
      'destinatario': destinatario,
      'direccion_destino': direccionDestino,
      'observacion': observacion,
      'productos': productos,
    };

    final respuesta = await http.post(
      Uri.parse('$urlBase/ordenes-despacho'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(datos),
    );

    final resultado = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 201) {
      return Map<String, dynamic>.from(resultado);
    }

    throw Exception(
      resultado['message'] ??
          'No se pudo crear la orden de despacho.',
    );
  }

}