
import 'package:flutter/material.dart';

import '../almacenes/modelo_almacen.dart';
import '../almacenes/servicio_almacenes.dart';
import '../productos/modelo_producto.dart';
import '../productos/servicio_productos.dart';
import 'servicio_ordenes_despacho.dart';
import '../existencias/servicio_existencias.dart';

class PaginaNuevaOrdenDespacho extends StatefulWidget {
  const PaginaNuevaOrdenDespacho({super.key});

  @override
  State<PaginaNuevaOrdenDespacho> createState() =>
      _PaginaNuevaOrdenDespachoState();
}

class _PaginaNuevaOrdenDespachoState
    extends State<PaginaNuevaOrdenDespacho> {
  final _formulario = GlobalKey<FormState>();

  final _destinatario = TextEditingController();
  final _direccion = TextEditingController();
  final _observacion = TextEditingController();

  final _servicioAlmacenes = ServicioAlmacenes();
  final _servicioProductos = ServicioProductos();
  final _servicioOrdenes = ServicioOrdenesDespacho();
  final _servicioExistencias = ServicioExistencias();

  List<Almacen> _almacenes = [];
  List<Producto> _productos = [];

  String? _almacenSeleccionado;
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  final List<_ProductoDespacho> _detalles = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final almacenes = await _servicioAlmacenes.obtenerAlmacenes();
      final productos = await _servicioProductos.obtenerProductos();

      if (!mounted) return;

      setState(() {
        _almacenes = almacenes.where((a) => a.activo).toList();
        _productos = productos;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _cargando = false;
      });
    }
  }

  void _agregarProducto() {
    setState(() {
      _detalles.add(_ProductoDespacho());
    });
  }

  void _eliminarProducto(int indice) {
    setState(() {
      _detalles.removeAt(indice);
    });
  }

  // Validar existencias antes de registrar la orden.
Future<bool> _validarExistencias(
  List<Map<String, dynamic>> productosOrden,
) async {
  final almacenId = _almacenSeleccionado;

  if (almacenId == null) return false;

  for (final item in productosOrden) {
    final productoId = item['producto_id'].toString();
    final cantidadSolicitada = item['cantidad'] as int;

    final disponible = await _consultarStockDisponible(
      productoId,
      almacenId,
    );

    if (cantidadSolicitada > disponible) {
      final producto = _productos.firstWhere(
        (p) => p.id == productoId,
      );

      _mostrarMensaje(
        'Stock insuficiente para ${producto.nombre}. '
        'Disponible: $disponible. '
        'Solicitado: $cantidadSolicitada.',
        Colors.red,
      );

      return false;
    }
  }

  return true;
}

  Future<void> _guardarOrden() async {
    if (_guardando) return;

    if (!_formulario.currentState!.validate()) return;

    if (_almacenSeleccionado == null) {
      _mostrarMensaje('Selecciona un almacén.', Colors.orange);
      return;
    }

    if (_detalles.isEmpty) {
      _mostrarMensaje('Agrega al menos un producto.', Colors.orange);
      return;
    }

    final productosOrden = <Map<String, dynamic>>[];
    final ids = <int>{};

    for (final detalle in _detalles) {
      final id = int.tryParse(detalle.productoId ?? '');
      final cantidad = int.tryParse(detalle.cantidad.text.trim());

      if (id == null || cantidad == null || cantidad <= 0) {
        _mostrarMensaje(
          'Selecciona productos y cantidades válidas.',
          Colors.orange,
        );
        return;
      }

      if (!ids.add(id)) {
        _mostrarMensaje(
          'No puedes repetir el mismo producto.',
          Colors.orange,
        );
        return;
      }

      final stockDisponible = await _consultarStockDisponible(
        detalle.productoId!,
        _almacenSeleccionado!,
      );

      if (cantidad > stockDisponible) {
        final producto = _productos.firstWhere(
          (item) => item.id == detalle.productoId,
        );
        _mostrarMensaje(
          'Stock insuficiente para ${producto.nombre}: '
          'disponible $stockDisponible, solicitado $cantidad.',
          Colors.orange,
        );
        return;
      }

      productosOrden.add({
        'producto_id': id,
        'cantidad': cantidad,
      });
    }

    setState(() => _guardando = true);

try {
  final existenciasValidas = await _validarExistencias(
    productosOrden,
  );

  if (!existenciasValidas) return;
} catch (error) {
  if (!mounted) return;

  _mostrarMensaje(
    'No se pudieron verificar las existencias: $error',
    Colors.red,
  );
  return;
} finally {
  if (mounted) {
    setState(() => _guardando = false);
  }
}

if (!mounted) return;

setState(() => _guardando = true);

    try {
      await _servicioOrdenes.crearOrden(
        almacenId: int.parse(_almacenSeleccionado!),
        destinatario: _destinatario.text.trim(),
        direccionDestino: _direccion.text.trim(),
        observacion: _observacion.text.trim(),
        productos: productosOrden,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        'No se pudo crear la orden: $error',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _destinatario.dispose();
    _direccion.dispose();
    _observacion.dispose();

    for (final detalle in _detalles) {
      detalle.dispose();
    }

    super.dispose();
  }

  // Consultar las unidades disponibles de un producto
// en el almacén seleccionado.
Future<int> _consultarStockDisponible(
  String productoId,
  String almacenId,
) async {
  final existencias = await _servicioExistencias.obtenerExistencias(
    productoId: productoId,
    almacenId: almacenId,
  );

  return existencias
      .where(
        (existencia) =>
            existencia.productoId == productoId &&
            existencia.almacenId == almacenId,
      )
      .fold<int>(
        0,
        (total, existencia) => total + existencia.cantidad,
      );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva orden de despacho'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Form(
                  key: _formulario,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'Información del despacho',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Almacén de origen',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _almacenSeleccionado,
                        items: _almacenes.map((almacen) {
                          return DropdownMenuItem(
                            value: almacen.id,
                            child: Text(almacen.nombre),
                          );
                        }).toList(),
                        onChanged: _guardando
                            ? null
                            : (valor) {
                                setState(() {
                                  _almacenSeleccionado = valor;
                                });
                              },
                        validator: (valor) =>
                            valor == null ? 'Selecciona un almacén' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _destinatario,
                        decoration: const InputDecoration(
                          labelText: 'Destinatario',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) =>
                            valor == null || valor.trim().isEmpty
                                ? 'Ingresa el destinatario'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _direccion,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Dirección de entrega',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) =>
                            valor == null || valor.trim().isEmpty
                                ? 'Ingresa la dirección'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _observacion,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Productos del despacho',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                _guardando ? null : _agregarProducto,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar producto'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      for (int i = 0; i < _detalles.length; i++)
                        _construirFilaProducto(i),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _guardando
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed:
                                _guardando ? null : _guardarOrden,
                            icon: _guardando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _guardando
                                  ? 'Guardando...'
                                  : 'Crear orden',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _mostrarStockDisponible(String? productoId) {
  if (productoId == null || _almacenSeleccionado == null) {
    return const SizedBox.shrink();
  }

  return FutureBuilder<int>(
    key: ValueKey('$productoId-$_almacenSeleccionado'),
    future: _consultarStockDisponible(
      productoId,
      _almacenSeleccionado!,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        );
      }

      if (snapshot.hasError) {
        return const Text(
          'No se pudo consultar el stock disponible.',
          style: TextStyle(color: Colors.red),
        );
      }

      final disponible = snapshot.data ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              'Disponible en este almacén: $disponible unidades',
              style: TextStyle(
                color: disponible > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _construirFilaProducto(int indice) {
    final detalle = _detalles[indice];

    return Card(
      key: ObjectKey(detalle),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: detalle.productoId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Producto',
                border: OutlineInputBorder(),
              ),
              items: _productos.map((producto) {
                return DropdownMenuItem(
                  value: producto.id,
                  child: Text(
                    '${producto.nombre} (${producto.sku})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _guardando
                  ? null
                  : (valor) {
                      setState(() {
                        detalle.productoId = valor;
                      });
                    },
              validator: (valor) =>
                valor == null ? 'Selecciona un producto' : null,
            ),
            _mostrarStockDisponible(detalle.productoId),
            const SizedBox(height: 12),
            TextFormField(
              controller: detalle.cantidad,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final cantidad = int.tryParse(valor?.trim() ?? '');

                if (cantidad == null || cantidad <= 0) {
                  return 'Ingresa una cantidad válida';
                }

                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Eliminar producto',
                onPressed: _guardando
                    ? null
                    : () => _eliminarProducto(indice),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductoDespacho {
  String? productoId;
  final TextEditingController cantidad =
      TextEditingController(text: '1');

  void dispose() {
    cantidad.dispose();
  }
}
