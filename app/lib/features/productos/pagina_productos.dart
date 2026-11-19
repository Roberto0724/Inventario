import 'package:flutter/material.dart';

import 'formulario_producto.dart';
import 'modelo_producto.dart';
import 'servicio_productos.dart';
import 'pagina_papelera_productos.dart';

class PaginaProductos extends StatefulWidget {
  const PaginaProductos({super.key});

  @override
  State<PaginaProductos> createState() => _EstadoPaginaProductos();
}

class _EstadoPaginaProductos extends State<PaginaProductos> {
  final TextEditingController controladorBusqueda = TextEditingController();

  final ServicioProductos servicioProductos = ServicioProductos();

  List<Producto> productos = [];

  bool cargandoProductos = true;
  String? errorProductos;

  Future<void> registrarProducto() async {
    final nuevoProducto = await Navigator.of(context).push<Producto>(
      MaterialPageRoute(builder: (_) => const FormularioProducto()),
    );

    if (!mounted || nuevoProducto == null) return;

    final skuExiste = productos.any(
      (producto) =>
          producto.sku.toLowerCase() == nuevoProducto.sku.toLowerCase(),
    );

    if (skuExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe un producto con ese SKU')),
      );
      return;
    }

    try {
      // Guardar el producto mediante la API Laravel.
      await servicioProductos.registrarProducto(nuevoProducto);

      if (!mounted) return;

      // Consultar nuevamente los productos desde PostgreSQL.
      await cargarProductos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto registrado correctamente en PostgreSQL'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar el producto: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editarProducto(Producto productoActual) async {
    final productoActualizado = await Navigator.of(context).push<Producto>(
      MaterialPageRoute(
        builder: (_) => FormularioProducto(producto: productoActual),
      ),
    );

    if (!mounted || productoActualizado == null) return;

    final skuDuplicado = productos.any(
      (producto) =>
          producto.id != productoActualizado.id &&
          producto.sku.toLowerCase() == productoActualizado.sku.toLowerCase(),
    );

    if (skuDuplicado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe otro producto con ese SKU')),
      );
      return;
    }

    try {
      // Actualizar el producto mediante Laravel.
      await servicioProductos.actualizarProducto(productoActualizado);

      if (!mounted) return;

      // Recargar los productos desde PostgreSQL.
      await cargarProductos();

      if (!mounted) return;

      if (errorProductos != null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el producto: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> eliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Estás seguro de que deseas enviar "${producto.nombre}" a la papelera?\n\n'
          'Podrás restaurarlo posteriormente desde la Papelera de productos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(contextoDialogo, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true) return;

    try {
      // Eliminar el producto mediante Laravel.
      await servicioProductos.eliminarProducto(producto.id);

      if (!mounted) return;

      // Recargar los productos desde PostgreSQL.
      await cargarProductos();

      if (!mounted) return;

      if (errorProductos != null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto enviado a la papelera correctamente'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el producto: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> abrirPapelera() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (contexto) => const PaginaPapeleraProductos()),
    );

    if (!mounted) return;

    await cargarProductos();
  }

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    setState(() {
      cargandoProductos = true;
      errorProductos = null;
    });

    try {
      final productosObtenidos = await servicioProductos.obtenerProductos();

      if (!mounted) return;

      setState(() {
        productos = productosObtenidos;
        cargandoProductos = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorProductos = 'No se pudieron cargar los productos: $error';
        cargandoProductos = false;
      });
    }
  }

  @override
  void dispose() {
    controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busqueda = controladorBusqueda.text.toLowerCase().trim();

    final productosFiltrados = productos.where((producto) {
      return producto.nombre.toLowerCase().contains(busqueda) ||
          producto.sku.toLowerCase().contains(busqueda) ||
          producto.codigoBarras.contains(busqueda);
    }).toList();

    if (cargandoProductos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorProductos != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorProductos!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: cargarProductos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text('Administración del catálogo de productos'),
              ],
            ),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: abrirPapelera,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Papelera'),
                ),
                FilledButton.icon(
                  onPressed: registrarProducto,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo producto'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controladorBusqueda,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, SKU o código de barras',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Producto')),
                DataColumn(label: Text('Categoría')),
                DataColumn(label: Text('Precio')),
                DataColumn(label: Text('Existencia')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: productosFiltrados.map((producto) {
                return DataRow(
                  cells: [
                    DataCell(Text(producto.sku)),
                    DataCell(Text(producto.nombre)),
                    DataCell(Text(producto.categoria)),
                    DataCell(Text('\$${producto.precio.toStringAsFixed(2)}')),
                    DataCell(Text('${producto.existencia}')),
                    DataCell(
                      Text(
                        producto.tieneExistenciaBaja
                            ? 'Existencia baja'
                            : 'Disponible',
                        style: TextStyle(
                          color: producto.tieneExistenciaBaja
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar producto',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => editarProducto(producto),
                          ),
                          IconButton(
                            tooltip: 'Eliminar producto',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => eliminarProducto(producto),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
