import 'dart:convert';

import 'package:http/http.dart' as http;

import '../productos/servicio_productos.dart';
import '../almacenes/servicio_almacenes.dart';
import '../existencias/servicio_existencias.dart';
import '../movimientos/modelo_movimiento_inventario.dart';

class EstadisticasDashboard {
  final int totalProductos;
  final int totalAlmacenes;
  final int productosStockBajo;
  final int totalMovimientos;
  final List<MovimientoInventario> movimientosRecientes;

  const EstadisticasDashboard({
    required this.totalProductos,
    required this.totalAlmacenes,
    required this.productosStockBajo,
    required this.totalMovimientos,
    required this.movimientosRecientes,
  });
}

class ServicioDashboard {
  static const String urlBase = 'http://127.0.0.1:8000/api';
  final _servicioProductos = ServicioProductos();
  final _servicioAlmacenes = ServicioAlmacenes();
  final _servicioExistencias = ServicioExistencias();

  Future<EstadisticasDashboard> obtenerEstadisticas() async {
    final productos = await _servicioProductos.obtenerProductos();
    final almacenes = await _servicioAlmacenes.obtenerAlmacenes();
    final existencias = await _servicioExistencias.obtenerExistencias();
    final uri = Uri.parse('$urlBase/movimientos-inventario?page=1');
    final respuesta = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar movimientos: HTTP ${respuesta.statusCode}',
      );
    }
    final datos = jsonDecode(respuesta.body);
    if (datos is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de movimientos inválida.');
    }
    final registros = datos['data'];
    if (registros is! List) {
      throw const FormatException('La API no devolvió movimientos válidos.');
    }
    final total = int.tryParse(datos['total']?.toString() ?? '');
    if (total == null) {
      throw const FormatException(
        'La API no devolvió el total de movimientos.',
      );
    }
    final movimientos = registros
        .map(
          (registro) => MovimientoInventario.desdeJson(
            Map<String, dynamic>.from(registro as Map),
          ),
        )
        .toList();
    // La API debe entregar la primera página ordenada del más reciente al más antiguo.
    movimientos.sort((a, b) {
      final fechaA = a.fecha;
      final fechaB = b.fecha;
      if (fechaA != null && fechaB != null) {
        final orden = fechaB.compareTo(fechaA);
        if (orden != 0) return orden;
      }
      return b.id.compareTo(a.id);
    });

    final cantidadesPorProducto = <String, int>{};
    for (final existencia in existencias) {
      cantidadesPorProducto.update(
        existencia.productoId,
        (actual) => actual + existencia.cantidad,
        ifAbsent: () => existencia.cantidad,
      );
    }
    final stockBajo = productos.where((producto) {
      return (cantidadesPorProducto[producto.id] ?? 0) <=
          producto.existenciaMinima;
    }).length;

    return EstadisticasDashboard(
      totalProductos: productos.length,
      totalAlmacenes: almacenes.where((almacen) => almacen.activo).length,
      productosStockBajo: stockBajo,
      totalMovimientos: total,
      movimientosRecientes: movimientos.take(5).toList(),
    );
  }
}
