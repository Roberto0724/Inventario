
import 'package:flutter/material.dart';

import 'servicio_movimientos.dart';
import '../productos/modelo_producto.dart';
import '../productos/servicio_productos.dart';
import '../almacenes/modelo_almacen.dart';
import '../almacenes/servicio_almacenes.dart';

class FormularioSalida extends StatefulWidget {
  const FormularioSalida({super.key});

  @override
  State<FormularioSalida> createState() => _FormularioSalidaState();
}

class _FormularioSalidaState extends State<FormularioSalida> {
  final _formulario = GlobalKey<FormState>();

  final _servicio = ServicioMovimientos();
  final _servicioProductos = ServicioProductos();
  final _servicioAlmacenes = ServicioAlmacenes();

  final _cantidad = TextEditingController();
  final _referencia = TextEditingController();
  final _observacion = TextEditingController();

  List<Producto> _productos = [];
  List<Almacen> _almacenes = [];

  String? _productoSeleccionado;
  String? _almacenSeleccionado;
  String? _errorOpciones;

  bool _cargandoOpciones = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  Future<void> _cargarOpciones() async {
    setState(() {
      _cargandoOpciones = true;
      _errorOpciones = null;
    });

    try {
      final productos = await _servicioProductos.obtenerProductos();
      final almacenes = await _servicioAlmacenes.obtenerAlmacenes();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _almacenes = almacenes
            .where((almacen) => almacen.activo)
            .toList();
        _productoSeleccionado = null;
        _almacenSeleccionado = null;
        _cargandoOpciones = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorOpciones = error.toString();
        _cargandoOpciones = false;
      });
    }
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _referencia.dispose();
    _observacion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || _cargandoOpciones) return;
    if (!_formulario.currentState!.validate()) return;

    final productoId = int.tryParse(_productoSeleccionado ?? '');
    final almacenId = int.tryParse(_almacenSeleccionado ?? '');
    final cantidad = int.tryParse(_cantidad.text.trim());

    if (productoId == null ||
        almacenId == null ||
        cantidad == null ||
        cantidad <= 0) {
      return;
    }

    setState(() => _guardando = true);

    try {
      await _servicio.registrarSalida(
        productoId: productoId,
        almacenOrigenId: almacenId,
        cantidad: cantidad,
        referencia: _referencia.text.trim().isEmpty
            ? null
            : _referencia.text.trim(),
        observacion: _observacion.text.trim().isEmpty
            ? null
            : _observacion.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar salida: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoOpciones) {
      return const AlertDialog(
        title: Text('Cargando información'),
        content: SizedBox(
          width: 400,
          height: 90,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_errorOpciones != null) {
      return AlertDialog(
        title: const Text('Error al cargar datos'),
        content: Text(_errorOpciones!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: _cargarOpciones,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Registrar salida de inventario'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _productoSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Producto',
                    border: OutlineInputBorder(),
                  ),
                  items: _productos.map((producto) {
                    return DropdownMenuItem<String>(
                      value: producto.id,
                      child: Text(
                        '${producto.nombre} — ${producto.sku}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) {
                          setState(() {
                            _productoSeleccionado = valor;
                          });
                        },
                  validator: (valor) => valor == null
                      ? 'Selecciona un producto'
                      : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _almacenSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Almacén de origen',
                    border: OutlineInputBorder(),
                  ),
                  items: _almacenes.map((almacen) {
                    return DropdownMenuItem<String>(
                      value: almacen.id,
                      child: Text(
                        '${almacen.nombre} — ${almacen.codigo}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) {
                          setState(() {
                            _almacenSeleccionado = valor;
                          });
                        },
                  validator: (valor) => valor == null
                      ? 'Selecciona un almacén'
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _cantidad,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad a retirar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final cantidad = int.tryParse(valor?.trim() ?? '');

                    if (cantidad == null || cantidad <= 0) {
                      return 'Ingresa una cantidad mayor que cero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _referencia,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Referencia (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _observacion,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observación (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _guardando ? null : _guardar,
          icon: _guardando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.remove_circle_outline),
          label: const Text('Guardar salida'),
        ),
      ],
    );
  }
}
