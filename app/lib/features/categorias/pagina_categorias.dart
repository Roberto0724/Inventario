import 'package:flutter/material.dart';

import 'formulario_categoria.dart';
import 'modelo_categoria.dart';
import 'servicio_categorias.dart';

class PaginaCategorias extends StatefulWidget {
  const PaginaCategorias({super.key});

  @override
  State<PaginaCategorias> createState() => _PaginaCategoriasState();
}

class _PaginaCategoriasState extends State<PaginaCategorias> {
  final ServicioCategorias servicioCategorias = ServicioCategorias();

  List<Categoria> categorias = [];
  bool cargandoCategorias = true;
  String? errorCategorias;
  String busqueda = '';

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    setState(() {
      cargandoCategorias = true;
      errorCategorias = null;
    });

    try {
      final resultado = await servicioCategorias.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        categorias = resultado;
        cargandoCategorias = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorCategorias = error.toString();
        cargandoCategorias = false;
      });
    }
  }

  Future<void> registrarCategoria() async {
    final nuevaCategoria = await showDialog<Categoria>(
      context: context,
      builder: (contexto) => const FormularioCategoria(),
    );

    if (!mounted || nuevaCategoria == null) return;

    try {
      await servicioCategorias.registrarCategoria(nuevaCategoria);

      if (!mounted) return;

      await cargarCategorias();

      if (!mounted) return;

      if (errorCategorias != null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría registrada correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar la categoría: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editarCategoria(Categoria categoria) async {
    final categoriaActualizada = await showDialog<Categoria>(
      context: context,
      builder: (contexto) => FormularioCategoria(categoria: categoria),
    );

    if (!mounted || categoriaActualizada == null) return;

    try {
      await servicioCategorias.actualizarCategoria(categoriaActualizada);

      if (!mounted) return;

      await cargarCategorias();

      if (!mounted) return;

      if (errorCategorias != null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría actualizada correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la categoría: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> eliminarCategoria(Categoria categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Estás seguro de eliminar la categoría "${categoria.nombre}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true) return;

    try {
      await servicioCategorias.eliminarCategoria(categoria.id);

      if (!mounted) return;

      await cargarCategorias();

      if (!mounted) return;

      if (errorCategorias != null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría eliminada correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasFiltradas = categorias.where((categoria) {
      final texto = busqueda.toLowerCase();

      return categoria.nombre.toLowerCase().contains(texto) ||
          categoria.descripcion.toLowerCase().contains(texto);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorías',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Administración de categorías de productos'),
                ],
              ),
              FilledButton.icon(
                onPressed: registrarCategoria,
                icon: const Icon(Icons.add),
                label: const Text('Nueva categoría'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar categoría...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (valor) {
              setState(() {
                busqueda = valor;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: cargandoCategorias
                ? const Center(child: CircularProgressIndicator())
                : errorCategorias != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: $errorCategorias'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: cargarCategorias,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : categoriasFiltradas.isEmpty
                ? const Center(child: Text('No hay categorías para mostrar'))
                : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Descripción')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: categoriasFiltradas.map((categoria) {
                          return DataRow(
                            cells: [
                              DataCell(Text(categoria.id)),
                              DataCell(Text(categoria.nombre)),
                              DataCell(Text(categoria.descripcion)),
                              DataCell(
                                Chip(
                                  label: Text(
                                    categoria.activo ? 'Activa' : 'Inactiva',
                                  ),
                                ),
                              ),

                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Editar categoría',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          editarCategoria(categoria),
                                    ),
                                    IconButton(
                                      tooltip: 'Eliminar categoría',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          eliminarCategoria(categoria),
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
          ),
        ],
      ),
    );
  }
}
