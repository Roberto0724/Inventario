import 'package:flutter/material.dart';

import 'features/productos/pagina_productos.dart';
import 'features/categorias/pagina_categorias.dart';
import 'features/almacenes/pagina_almacenes.dart';
import 'features/existencias/pagina_existencias.dart';
import 'features/movimientos/pagina_movimientos.dart';
import 'features/dashboard/servicio_dashboard.dart';
import 'features/movimientos/modelo_movimiento_inventario.dart';
import 'features/logistica/pagina_ordenes_despacho.dart';

void main() {
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario ERP Logistics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF155E75)),
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
      ),
      home: const PaginaPrincipal(),
    );
  }
}

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int indiceSeleccionado = 0;

  final ServicioDashboard _servicioDashboard = ServicioDashboard();
  late Future<EstadisticasDashboard> _estadisticasDashboard;

  final List<String> secciones = [
    'Dashboard',
    'Productos',
    'Categorías',
    'Almacenes',
    'Existencias',
    'Movimientos',
    'Logística',
    'Licencias',
  ];

  final List<IconData> iconosSecciones = [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.category_outlined,
    Icons.warehouse_outlined,
    Icons.inventory_outlined,
    Icons.swap_horiz_outlined,
    Icons.local_shipping_outlined,
    Icons.vpn_key_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _actualizarEstadisticas();
  }

  void _actualizarEstadisticas() {
    _estadisticasDashboard = _servicioDashboard.obtenerEstadisticas();
  }

  @override
  Widget build(BuildContext context) {
    final pantallaAncha = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventario ERP Logistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(child: Icon(Icons.person_outline)),
          ),
        ],
      ),
      drawer: pantallaAncha ? null : Drawer(child: construirMenu()),
      body: Row(
        children: [
          if (pantallaAncha) SizedBox(width: 240, child: construirMenu()),
          Expanded(child: construirContenido()),
        ],
      ),
    );
  }

  
Widget construirContenido() {
  switch (indiceSeleccionado) {
    case 0:
      return construirPanelPrincipal();

    case 1:
      return const PaginaProductos();

    case 2:
      return const PaginaCategorias();

    case 3:
      return const PaginaAlmacenes();

    case 4:
      return const PaginaExistencias();

    case 5:
      return const PaginaMovimientos();

    case 6:
      return const PaginaOrdenesDespacho();

    default:
      return Center(
        child: Text(
          secciones[indiceSeleccionado],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
  }
}


  Widget construirMenu() {
    return Material(
      color: const Color(0xFF102A43),
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'INVENTARIO ERP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (int indice = 0; indice < secciones.length; indice++)
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(iconosSecciones[indice], color: Colors.white70),
                  title: Text(
                    secciones[indice],
                    style: const TextStyle(color: Colors.white),
                  ),
                  selected: indiceSeleccionado == indice,
                  selectedTileColor: Colors.white12,
                  onTap: () {
                    setState(() {
                      indiceSeleccionado = indice;
                      if (indice == 0) _actualizarEstadisticas();
                    });
                    if (MediaQuery.sizeOf(context).width < 850) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget construirPanelPrincipal() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Panel principal',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Resumen general de las operaciones de inventario',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => setState(_actualizarEstadisticas),
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<EstadisticasDashboard>(
          future: _estadisticasDashboard,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar estadísticas: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => setState(_actualizarEstadisticas),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Text('No hay estadísticas disponibles.'),
              );
            }

            final estadisticas = snapshot.data!;
            return LayoutBuilder(
              builder: (context, restricciones) {
                final columnas = restricciones.maxWidth >= 900
                    ? 4
                    : restricciones.maxWidth >= 500
                    ? 2
                    : 1;
                return GridView.count(
                  crossAxisCount: columnas,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 160,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    construirTarjetaEstadistica(
                      'Total productos',
                      estadisticas.totalProductos.toString(),
                      Icons.inventory_2_outlined,
                      Colors.blue,
                    ),
                    construirTarjetaEstadistica(
                      'Almacenes',
                      estadisticas.totalAlmacenes.toString(),
                      Icons.warehouse_outlined,
                      Colors.green,
                    ),
                    construirTarjetaEstadistica(
                      'Movimientos',
                      estadisticas.totalMovimientos.toString(),
                      Icons.swap_horiz,
                      Colors.orange,
                    ),
                    construirTarjetaEstadistica(
                      'Stock bajo',
                      estadisticas.productosStockBajo.toString(),
                      Icons.warning_amber_outlined,
                      Colors.red,
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        FutureBuilder<EstadisticasDashboard>(
          future: _estadisticasDashboard,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done ||
                snapshot.hasError ||
                !snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final movimientos = snapshot.data!.movimientosRecientes;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actividad reciente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    if (movimientos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Todavía no hay movimientos registrados.'),
                      )
                    else
                      for (final movimiento in movimientos)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            _iconoMovimiento(movimiento.tipo),
                            color: _colorMovimiento(movimiento.tipo),
                          ),
                          title: Text(
                            '${movimiento.tipo.toUpperCase()} · ${movimiento.nombreProducto}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(_detalleMovimiento(movimiento)),
                          trailing: Text('${movimiento.cantidad} uds.'),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _iconoMovimiento(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return Icons.arrow_downward;
      case 'salida':
        return Icons.arrow_upward;
      case 'transferencia':
        return Icons.swap_horiz;
      default:
        return Icons.history;
    }
  }

  Color _colorMovimiento(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return Colors.green;
      case 'salida':
        return Colors.orange;
      case 'transferencia':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _detalleMovimiento(MovimientoInventario movimiento) {
    final origen = movimiento.almacenOrigen;
    final destino = movimiento.almacenDestino;
    final ubicacion = [
      if (origen != null && origen.isNotEmpty) 'Origen: $origen',
      if (destino != null && destino.isNotEmpty) 'Destino: $destino',
    ].join(' · ');
    final fecha = movimiento.fecha;
    final fechaTexto = fecha == null
        ? ''
        : '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    return [
      ubicacion,
      fechaTexto,
    ].where((texto) => texto.isNotEmpty).join(' · ');
  }

  Widget construirTarjetaEstadistica(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 32, color: color),
            const SizedBox(height: 10),
            Text(
              valor,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
