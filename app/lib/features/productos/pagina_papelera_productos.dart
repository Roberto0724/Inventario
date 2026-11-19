import 'package:flutter/material.dart';

import 'modelo_producto.dart';
import 'servicio_productos.dart';

class PaginaPapeleraProductos extends StatefulWidget {
  const PaginaPapeleraProductos({super.key});

  @override
  State<PaginaPapeleraProductos> createState() =>
      _PaginaPapeleraProductosState();
}

class _PaginaPapeleraProductosState extends State<PaginaPapeleraProductos> {
  final ServicioProductos servicioProductos = ServicioProductos();

  List<Producto> productosEliminados = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarPapelera();
  }

  Future<void> cargarPapelera() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final productos = await servicioProductos.obtenerPapelera();

      if (!mounted) return;

      setState(() {
        productosEliminados = productos;
        cargando = false;
      });
    } catch (excepcion) {
      if (!mounted) return;

      setState(() {
        error = excepcion.toString();
        cargando = false;
      });
    }
  }

  Future<void> restaurarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Restaurar producto'),
        content: Text('¿Deseas restaurar el producto "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true) return;

    try {
      await servicioProductos.restaurarProducto(producto.id);

      if (!mounted) return;

      await cargarPapelera();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto restaurado correctamente')),
      );
    } catch (excepcion) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al restaurar: $excepcion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papelera de productos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargarPapelera,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : productosEliminados.isEmpty
          ? const Center(child: Text('La papelera está vacía'))
          : ListView.builder(
              itemCount: productosEliminados.length,
              itemBuilder: (context, indice) {
                final producto = productosEliminados[indice];

                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(producto.nombre),
                  subtitle: Text(
                    'SKU: ${producto.sku} | '
                    'Categoría: ${producto.categoria}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Restaurar producto',
                    icon: const Icon(Icons.restore),
                    onPressed: () => restaurarProducto(producto),
                  ),
                );
              },
            ),
    );
  }
}
