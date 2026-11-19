import 'package:flutter/material.dart';

import 'formulario_almacen.dart';
import 'modelo_almacen.dart';
import 'servicio_almacenes.dart';
import 'pagina_papelera_almacenes.dart';

class PaginaAlmacenes extends StatefulWidget {
  const PaginaAlmacenes({super.key});

  @override
  State<PaginaAlmacenes> createState() => _EstadoPaginaAlmacenes();
}

class _EstadoPaginaAlmacenes extends State<PaginaAlmacenes> {
  final ServicioAlmacenes servicioAlmacenes = ServicioAlmacenes();
  final TextEditingController controladorBusqueda = TextEditingController();

  List<Almacen> almacenes = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarAlmacenes();
  }

  @override
  void dispose() {
    controladorBusqueda.dispose();
    super.dispose();
  }

  Future<void> cargarAlmacenes() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado = await servicioAlmacenes.obtenerAlmacenes();

      if (!mounted) return;

      setState(() {
        almacenes = resultado;
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

  Future<void> registrarAlmacen() async {
    final nuevoAlmacen = await Navigator.of(context).push<Almacen>(
      MaterialPageRoute(builder: (_) => const FormularioAlmacen()),
    );

    if (!mounted || nuevoAlmacen == null) return;

    try {
      await servicioAlmacenes.registrarAlmacen(nuevoAlmacen);

      if (!mounted) return;

      await cargarAlmacenes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Almacén registrado correctamente')),
      );
    } catch (excepcion) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $excepcion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editarAlmacen(Almacen almacenActual) async {
    final almacenActualizado = await Navigator.of(context).push<Almacen>(
      MaterialPageRoute(
        builder: (_) => FormularioAlmacen(almacen: almacenActual),
      ),
    );

    if (!mounted || almacenActualizado == null) return;

    try {
      await servicioAlmacenes.actualizarAlmacen(almacenActualizado);

      if (!mounted) return;

      await cargarAlmacenes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Almacén actualizado correctamente')),
      );
    } catch (excepcion) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $excepcion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> eliminarAlmacen(Almacen almacen) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Enviar almacén a la papelera'),
        content: Text(
          '¿Deseas enviar "${almacen.nombre}" a la papelera?\n\n'
          'El almacén dejará de aparecer en el listado. '
          'Sus datos permanecerán guardados para una futura restauración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true) return;

    try {
      await servicioAlmacenes.eliminarAlmacen(almacen.id);

      if (!mounted) return;

      await cargarAlmacenes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Almacén enviado a la papelera correctamente'),
        ),
      );
    } catch (excepcion) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $excepcion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> abrirPapelera() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PaginaPapeleraAlmacenes()));

    if (!mounted) return;

    await cargarAlmacenes();
  }

  @override
  Widget build(BuildContext context) {
    final busqueda = controladorBusqueda.text.toLowerCase().trim();

    final almacenesFiltrados = almacenes.where((almacen) {
      return almacen.nombre.toLowerCase().contains(busqueda) ||
          almacen.codigo.toLowerCase().contains(busqueda) ||
          almacen.ubicacion.toLowerCase().contains(busqueda);
    }).toList();

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
                  'Almacenes',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text('Administración de almacenes y ubicaciones'),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: registrarAlmacen,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo almacén'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: abrirPapelera,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Papelera'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controladorBusqueda,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre, código o ubicación',
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
                Text('No se pudieron cargar los almacenes: $error'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: cargarAlmacenes,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else if (almacenesFiltrados.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No se encontraron almacenes'),
            ),
          )
        else
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Código')),
                  DataColumn(label: Text('Almacén')),
                  DataColumn(label: Text('Ubicación')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: almacenesFiltrados.map((almacen) {
                  return DataRow(
                    cells: [
                      DataCell(Text(almacen.codigo)),
                      DataCell(Text(almacen.nombre)),
                      DataCell(Text(almacen.ubicacion)),
                      DataCell(
                        Text(
                          almacen.activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: almacen.activo ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar almacén',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => editarAlmacen(almacen),
                            ),
                            IconButton(
                              tooltip: 'Eliminar almacén',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => eliminarAlmacen(almacen),
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
