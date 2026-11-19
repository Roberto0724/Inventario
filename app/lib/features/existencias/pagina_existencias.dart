import 'package:flutter/material.dart';

import 'modelo_existencia_almacen.dart';
import 'servicio_existencias.dart';

class PaginaExistencias extends StatefulWidget {
  const PaginaExistencias({super.key});

  @override
  State<PaginaExistencias> createState() => _EstadoPaginaExistencias();
}

class _EstadoPaginaExistencias extends State<PaginaExistencias> {
  final ServicioExistencias servicioExistencias = ServicioExistencias();
  final TextEditingController controladorBusqueda = TextEditingController();

  List<ExistenciaAlmacen> existencias = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarExistencias();
  }

  @override
  void dispose() {
    controladorBusqueda.dispose();
    super.dispose();
  }

  Future<void> cargarExistencias() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado = await servicioExistencias.obtenerExistencias();

      if (!mounted) return;

      setState(() {
        existencias = resultado;
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

  @override
  Widget build(BuildContext context) {
    final busqueda = controladorBusqueda.text.trim().toLowerCase();

    final filtradas = existencias.where((existencia) {
      return existencia.nombreProducto.toLowerCase().contains(busqueda) ||
          existencia.skuProducto.toLowerCase().contains(busqueda) ||
          existencia.nombreAlmacen.toLowerCase().contains(busqueda) ||
          existencia.codigoAlmacen.toLowerCase().contains(busqueda);
    }).toList();

    final totalUnidades = existencias.fold<int>(
      0,
      (total, existencia) => total + existencia.cantidad,
    );

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
                  'Existencias por almacén',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Control de productos y cantidades por almacén',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: cargando ? null : cargarExistencias,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 36,
                  color: Color(0xFF155E75),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total de unidades registradas'),
                    Text(
                      '$totalUnidades',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controladorBusqueda,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Buscar producto o almacén',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        if (cargando)
          const Center(child: CircularProgressIndicator())
        else if (error != null)
          Center(
            child: Column(
              children: [
                Text('Error: $error'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: cargarExistencias,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else if (filtradas.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No se encontraron existencias.'),
            ),
          )
        else
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('SKU')),
                  DataColumn(label: Text('Almacén')),
                  DataColumn(label: Text('Código')),
                  DataColumn(label: Text('Cantidad')),
                ],
                rows: filtradas.map((existencia) {
                  return DataRow(
                    cells: [
                      DataCell(Text(existencia.nombreProducto)),
                      DataCell(Text(existencia.skuProducto)),
                      DataCell(Text(existencia.nombreAlmacen)),
                      DataCell(Text(existencia.codigoAlmacen)),
                      DataCell(
                        Text(
                          '${existencia.cantidad}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
