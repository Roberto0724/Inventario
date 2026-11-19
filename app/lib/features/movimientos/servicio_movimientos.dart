import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelo_movimiento_inventario.dart';

class ServicioMovimientos {
  static const String urlBase = 'http://127.0.0.1:8000/api';

  Future<List<MovimientoInventario>> obtenerMovimientos({
    int pagina = 1,
    String? tipo,
  }) async {
    final parametros = <String, String>{
      'page': pagina.toString(),
    };

    if (tipo != null && tipo.isNotEmpty) {
      parametros['tipo'] = tipo;
    }

    final uri = Uri.parse(
      '$urlBase/movimientos-inventario',
    ).replace(queryParameters: parametros);

    final respuesta = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar movimientos: '
        'HTTP ${respuesta.statusCode}',
      );
    }

    final json = jsonDecode(respuesta.body);

    if (json is! Map<String, dynamic>) {
      throw const FormatException(
        'Formato de respuesta inválido.',
      );
    }

    final registros = json['data'];

    if (registros is! List) {
      throw const FormatException(
        'La API no devolvió una lista de movimientos.',
      );
    }

    return registros
        .map(
          (registro) => MovimientoInventario.desdeJson(
            registro as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> registrarEntrada({
    required int productoId,
    required int almacenDestinoId,
    required int cantidad,
    String? referencia,
    String? observacion,
  }) async {
    if (cantidad <= 0) {
      throw ArgumentError('La cantidad debe ser mayor que cero.');
    }

    final uri = Uri.parse('$urlBase/movimientos-inventario');

    final respuesta = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'producto_id': productoId,
        'almacen_destino_id': almacenDestinoId,
        'cantidad': cantidad,
        'referencia': referencia,
        'observacion': observacion,
      }),
    );

    if (respuesta.statusCode != 201) {
      String mensaje = 'No se pudo registrar la entrada. '
          'HTTP ${respuesta.statusCode}';

      try {
        final datos = jsonDecode(respuesta.body);

        if (datos is Map<String, dynamic>) {
          final mensajeApi = datos['message'] ?? datos['mensaje'];

          if (mensajeApi is String && mensajeApi.isNotEmpty) {
            mensaje = mensajeApi;
          }
        }
      } catch (_) {
        // Conservamos el mensaje HTTP si la respuesta no es JSON.
      }

      throw Exception(mensaje);
    }
  }

  Future<void> registrarSalida({
    required int productoId,
    required int almacenOrigenId,
    required int cantidad,
    String? referencia,
    String? observacion,
  }) async {
    if (cantidad <= 0) {
      throw ArgumentError(
        'La cantidad debe ser mayor que cero.',
      );
    }

    final uri = Uri.parse(
      '$urlBase/movimientos-inventario/salida',
    );

    final respuesta = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'producto_id': productoId,
        'almacen_origen_id': almacenOrigenId,
        'cantidad': cantidad,
        'referencia': referencia,
        'observacion': observacion,
      }),
    );

    if (respuesta.statusCode != 201) {
      String mensaje =
          'No se pudo registrar la salida. '
          'HTTP ${respuesta.statusCode}';

      try {
        final datos = jsonDecode(respuesta.body);

        if (datos is Map<String, dynamic>) {
          final mensajeApi =
              datos['message'] ?? datos['mensaje'];

          if (mensajeApi is String &&
              mensajeApi.isNotEmpty) {
            mensaje = mensajeApi;
          }
        }
      } catch (_) {
        // Conservamos el mensaje HTTP si no es JSON.
      }

      throw Exception(mensaje);
    }
  }

Future<void> registrarTransferencia({
  required int productoId,
  required int almacenOrigenId,
  required int almacenDestinoId,
  required int cantidad,
  String? referencia,
  String? observacion,
}) async {
  if (cantidad <= 0) {
    throw ArgumentError(
      'La cantidad debe ser mayor que cero.',
    );
  }

  if (almacenOrigenId == almacenDestinoId) {
    throw ArgumentError(
      'El almacén de origen y destino deben ser diferentes.',
    );
  }

  final uri = Uri.parse(
    '$urlBase/movimientos-inventario/transferencia',
  );

  final respuesta = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'producto_id': productoId,
      'almacen_origen_id': almacenOrigenId,
      'almacen_destino_id': almacenDestinoId,
      'cantidad': cantidad,
      'referencia': referencia,
      'observacion': observacion,
    }),
  );

  if (respuesta.statusCode != 201) {
    String mensaje =
        'No se pudo registrar la transferencia. '
        'HTTP ${respuesta.statusCode}';

    try {
      final datos = jsonDecode(respuesta.body);

      if (datos is Map<String, dynamic>) {
        final mensajeApi =
            datos['message'] ?? datos['mensaje'];

        if (mensajeApi is String &&
            mensajeApi.isNotEmpty) {
          mensaje = mensajeApi;
        }
      }
    } catch (_) {
      // Conservamos el mensaje HTTP.
    }

    throw Exception(mensaje);
  }
}

}
