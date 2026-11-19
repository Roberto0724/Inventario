import 'dart:convert';

import 'package:http/http.dart' as http;

import 'modelo_producto.dart';

import 'package:flutter/foundation.dart';

class ServicioProductos {
  static const String urlBase = 'http://127.0.0.1:8000/api';

  // Consultar productos almacenados en PostgreSQL.
  Future<List<Producto>> obtenerProductos() async {
    final respuesta = await http.get(
      Uri.parse('$urlBase/productos'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudieron consultar los productos. '
        'Código: ${respuesta.statusCode}',
      );
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos.map((dato) {
      return Producto(
        id: dato['id'].toString(),
        nombre: dato['nombre'].toString(),
        sku: dato['sku'].toString(),
        codigoBarras: dato['codigo_barras']?.toString() ?? '',
        categoria: dato['categoria'].toString(),
        precio: double.parse(dato['precio'].toString()),
        existencia: int.parse(dato['existencia'].toString()),
        existenciaMinima: int.parse(dato['existencia_minima'].toString()),
      );
    }).toList();
  }

  // Registrar un producto en PostgreSQL mediante Laravel.
  Future<void> registrarProducto(Producto producto) async {
    final respuesta = await http.post(
      Uri.parse('$urlBase/productos'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': producto.nombre,
        'sku': producto.sku,
        'codigo_barras': producto.codigoBarras.isEmpty
            ? null
            : producto.codigoBarras,
        'categoria': producto.categoria,
        'precio': producto.precio,
        'existencia': producto.existencia,
        'existencia_minima': producto.existenciaMinima,
      }),
    );

    if (respuesta.statusCode != 201) {
      if (respuesta.statusCode == 422) {
        throw Exception(
          'Los datos del producto no son válidos o el SKU ya existe.',
        );
      }

      throw Exception(
        'No se pudo registrar el producto. '
        'Código: ${respuesta.statusCode}',
      );
    }
  }

  // Actualizar un producto existente en PostgreSQL.
  Future<void> actualizarProducto(Producto producto) async {
    debugPrint('ACTUALIZANDO PRODUCTO');
    debugPrint('ID: ${producto.id}');
    debugPrint('Nombre: ${producto.nombre}');
    debugPrint('SKU: ${producto.sku}');
    debugPrint('Precio: ${producto.precio}');
    debugPrint('Existencia: ${producto.existencia}');
    final respuesta = await http.put(
      Uri.parse('$urlBase/productos/${producto.id}'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': producto.nombre,
        'sku': producto.sku,
        'codigo_barras': producto.codigoBarras.isEmpty
            ? null
            : producto.codigoBarras,
        'categoria': producto.categoria,
        'precio': producto.precio,
        'existencia': producto.existencia,
        'existencia_minima': producto.existenciaMinima,
      }),
    );

    if (respuesta.statusCode != 200) {
      if (respuesta.statusCode == 422) {
        throw Exception(
          'Los datos no son válidos o el SKU ya está registrado.',
        );
      }

      throw Exception(
        'No se pudo actualizar el producto. '
        'Código: ${respuesta.statusCode}',
      );
    }
    debugPrint('PRODUCTO ACTUALIZADO EXITOSAMENTE');
  }

  // Eliminar un producto de PostgreSQL.
  Future<void> eliminarProducto(String id) async {
    final respuesta = await http.delete(
      Uri.parse('$urlBase/productos/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200 && respuesta.statusCode != 204) {
      throw Exception(
        'No se pudo eliminar el producto. '
        'Código: ${respuesta.statusCode}',
      );
    }
  }

  // Obtener productos eliminados.
  Future<List<Producto>> obtenerPapelera() async {
    final respuesta = await http.get(
      Uri.parse('$urlBase/productos/papelera'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo consultar la papelera: ${respuesta.body}');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos.map((dato) {
      return Producto(
        id: dato['id'].toString(),
        nombre: dato['nombre'].toString(),
        sku: dato['sku'].toString(),
        codigoBarras: dato['codigo_barras']?.toString() ?? '',
        categoria: dato['categoria'].toString(),
        precio: double.parse(dato['precio'].toString()),
        existencia: int.parse(dato['existencia'].toString()),
        existenciaMinima: int.parse(dato['existencia_minima'].toString()),
      );
    }).toList();
  }

  // Restaurar un producto eliminado.
  Future<void> restaurarProducto(String id) async {
    final respuesta = await http.patch(
      Uri.parse('$urlBase/productos/$id/restaurar'),
      headers: {'Accept': 'application/json'},
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo restaurar el producto: ${respuesta.body}');
    }
  }
}
