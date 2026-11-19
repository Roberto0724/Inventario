import 'package:flutter/material.dart';

import 'modelo_almacen.dart';
import 'servicio_almacenes.dart';

class PaginaPapeleraAlmacenes extends StatefulWidget {
  const PaginaPapeleraAlmacenes({super.key});

  @override
  State<PaginaPapeleraAlmacenes> createState() =>
      _EstadoPaginaPapeleraAlmacenes();
}

class _EstadoPaginaPapeleraAlmacenes extends State<PaginaPapeleraAlmacenes> {
  final ServicioAlmacenes servicioAlmacenes = ServicioAlmacenes();

  List<Almacen> almacenesEliminados = [];
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
      final resultado = await servicioAlmacenes.obtenerPapelera();

      if (!mounted) return;

      setState(() {
        almacenesEliminados = resultado;
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

  Future<void> restaurarAlmacen(Almacen almacen) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Restaurar almacén'),
        content: Text('¿Deseas restaurar el almacén "${almacen.nombre}"?'),
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
      await servicioAlmacenes.restaurarAlmacen(almacen.id);

      if (!mounted) return;

      await cargarPapelera();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Almacén restaurado correctamente')),
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
      appBar: AppBar(title: const Text('Papelera de almacenes')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: cargarPapelera,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : almacenesEliminados.isEmpty
            ? const Center(child: Text('No hay almacenes en la papelera.'))
            : ListView.separated(
                itemCount: almacenesEliminados.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, indice) {
                  final almacen = almacenesEliminados[indice];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warehouse_outlined),
                      title: Text(almacen.nombre),
                      subtitle: Text(
                        'Código: ${almacen.codigo}\n'
                        'Ubicación: ${almacen.ubicacion}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Restaurar almacén',
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () => restaurarAlmacen(almacen),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
