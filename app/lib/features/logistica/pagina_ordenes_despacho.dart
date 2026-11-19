import 'package:flutter/material.dart';
import 'servicio_ordenes_despacho.dart';
import 'pagina_nueva_orden_despacho.dart';

class PaginaOrdenesDespacho extends StatefulWidget {
  const PaginaOrdenesDespacho({super.key});

  @override
  State<PaginaOrdenesDespacho> createState() =>
      _PaginaOrdenesDespachoState();
}

class _PaginaOrdenesDespachoState extends State<PaginaOrdenesDespacho> {
  final ServicioOrdenesDespacho _servicio = ServicioOrdenesDespacho();
  late Future<List<dynamic>> _ordenes;
  bool _detalleAbierto = false;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  void _cargarOrdenes() {
    _ordenes = _servicio.obtenerOrdenes();
  }

  void _actualizar() {
    if (mounted) setState(_cargarOrdenes);
  }

  void _mostrarMensaje(String mensaje, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }

  Future<void> _abrirNuevaOrden() async {
    final creada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PaginaNuevaOrdenDespacho(),
      ),
    );
    if (!mounted) return;
    if (creada == true) {
      _actualizar();
      _mostrarMensaje('Orden de despacho creada correctamente.', Colors.green);
    }
  }

  Future<void> _mostrarDetalle(int idOrden) async {
    if (_detalleAbierto) return;
    _detalleAbierto = true;
    try {
      Map<String, dynamic> orden = await _servicio.obtenerOrden(idOrden);
      if (!mounted) return;

      bool procesando = false;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (contextoDialogo) => StatefulBuilder(
          builder: (contextoDialogo, actualizarDialogo) {
            Future<void> ejecutarAccion({required bool confirmar}) async {
              if (procesando) return;
              final accion = confirmar ? 'despachar' : 'cancelar';
              final autorizado = await showDialog<bool>(
                context: contextoDialogo,
                builder: (contextoConfirmacion) => AlertDialog(
                  title: Text(
                    confirmar ? 'Confirmar despacho' : 'Cancelar orden',
                  ),
                  content: Text(
                    '¿Deseas $accion esta orden?'
                    '${confirmar ? ' Esta operación descontará inventario.' : ''}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(contextoConfirmacion, false),
                      child: const Text('Volver'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(contextoConfirmacion, true),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );
              if (autorizado != true || !contextoDialogo.mounted || procesando) {
                return;
              }

              actualizarDialogo(() => procesando = true);
              try {
                if (confirmar) {
                  await _servicio.confirmarDespacho(idOrden);
                } else {
                  await _servicio.cancelarOrden(idOrden);
                }
                // Consultar el estado real para no mostrar datos obsoletos.
                final ordenActualizada = await _servicio.obtenerOrden(idOrden);
                if (!contextoDialogo.mounted) return;
                actualizarDialogo(() => orden = ordenActualizada);
                _actualizar();
                _mostrarMensaje(
                  confirmar
                      ? 'Orden despachada correctamente.'
                      : 'Orden cancelada correctamente.',
                  Colors.green,
                );
              } catch (error) {
                _actualizar();
                _mostrarMensaje(
                  'No se pudo $accion la orden o actualizar su detalle: $error',
                  Colors.red,
                );
              } finally {
                if (contextoDialogo.mounted) {
                  actualizarDialogo(() => procesando = false);
                }
              }
            }

            final almacen = orden['almacen'] as Map?;
            final detalles = orden['detalles'] as List? ?? [];
            final pendiente = orden['estado']?.toString() == 'pendiente';

            return PopScope(
              canPop: !procesando,
              child: AlertDialog(
                title: Text('Orden ${orden['numero_orden'] ?? idOrden}'),
                content: SizedBox(
                  width: 520,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Destinatario: ${orden['destinatario'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text('Dirección: ${orden['direccion_destino'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text('Almacén: ${almacen?['nombre'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text('Estado: ${orden['estado'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text(
                          'Observación: ${orden['observacion'] ?? 'Sin observación'}',
                        ),
                        const Divider(height: 32),
                        const Text(
                          'Productos del despacho',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final detalle in detalles)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${detalle['producto']?['nombre'] ?? 'Producto'}',
                                  ),
                                ),
                                Text(
                                  'Cantidad: ${detalle['cantidad']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (pendiente) ...[
                    OutlinedButton.icon(
                      onPressed: procesando
                          ? null
                          : () => ejecutarAccion(confirmar: false),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar orden'),
                    ),
                    FilledButton.icon(
                      onPressed: procesando
                          ? null
                          : () => ejecutarAccion(confirmar: true),
                      icon: procesando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.local_shipping_outlined),
                      label: const Text('Confirmar despacho'),
                    ),
                  ],
                  TextButton(
                    onPressed: procesando
                        ? null
                        : () => Navigator.pop(contextoDialogo),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } catch (error) {
      _mostrarMensaje('Error al consultar la orden: $error', Colors.red);
    } finally {
      _detalleAbierto = false;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'despachada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Órdenes de despacho',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gestión y seguimiento de despachos de inventario',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _actualizar,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _abrirNuevaOrden,
              icon: const Icon(Icons.add),
              label: const Text('Nueva orden'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: _ordenes,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 36),
                      const SizedBox(height: 12),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _actualizar,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final ordenes = snapshot.data ?? [];
            if (ordenes.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No hay órdenes de despacho registradas.'),
                ),
              );
            }
            return Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Orden')),
                    DataColumn(label: Text('Destinatario')),
                    DataColumn(label: Text('Almacén')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Fecha')),
                  ],
                  rows: ordenes.map<DataRow>((item) {
                    final orden = Map<String, dynamic>.from(item);
                    final almacen = orden['almacen'] as Map?;
                    final estado = orden['estado']?.toString() ?? 'pendiente';
                    final fecha = orden['created_at']?.toString() ?? '';
                    return DataRow(
                      onSelectChanged: (_) => _mostrarDetalle(orden['id'] as int),
                      cells: [
                        DataCell(Text(orden['numero_orden']?.toString() ?? '')),
                        DataCell(Text(orden['destinatario']?.toString() ?? '')),
                        DataCell(Text(almacen?['nombre']?.toString() ?? '')),
                        DataCell(
                          Text(
                            estado.toUpperCase(),
                            style: TextStyle(
                              color: _colorEstado(estado),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(fecha.length >= 10 ? fecha.substring(0, 10) : fecha),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
