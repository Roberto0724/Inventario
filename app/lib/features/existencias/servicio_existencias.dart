import 'dart:convert';

import 'package:http/http.dart' as http;

import 'modelo_existencia_almacen.dart';

class ServicioExistencias {
  static const String urlBase = 'http://127.0.0.1:8000/api';

  Future<List<ExistenciaAlmacen>> obtenerExistencias({
    String? productoId,
    String? almacenId,
  }) async {
    final parametros = <String, String>{};

    if (productoId != null && productoId.isNotEmpty) {
      parametros['producto_id'] = productoId;
    }

    if (almacenId != null && almacenId.isNotEmpty) {
      parametros['almacen_id'] = almacenId;
    }

    final uri = Uri.parse('$urlBase/existencias-almacen')
        .replace(queryParameters: parametros.isEmpty ? null : parametros);

    final respuesta = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar existencias: ${respuesta.statusCode}',
      );
    }

    final datos = jsonDecode(respuesta.body);

    if (datos is! List) {
      throw const FormatException(
        'La API no devolvió una lista de existencias.',
      );
    }

    return datos
        .map(
          (item) => ExistenciaAlmacen.desdeJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
