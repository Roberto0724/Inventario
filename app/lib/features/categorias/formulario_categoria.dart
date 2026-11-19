import 'package:flutter/material.dart';

import 'modelo_categoria.dart';

class FormularioCategoria extends StatefulWidget {
  final Categoria? categoria;

  const FormularioCategoria({super.key, this.categoria});

  @override
  State<FormularioCategoria> createState() => _FormularioCategoriaState();
}

class _FormularioCategoriaState extends State<FormularioCategoria> {
  final claveFormulario = GlobalKey<FormState>();

  final controladorNombre = TextEditingController();
  final controladorDescripcion = TextEditingController();

  bool activo = true;

  @override
  void initState() {
    super.initState();

    final categoria = widget.categoria;

    if (categoria != null) {
      controladorNombre.text = categoria.nombre;
      controladorDescripcion.text = categoria.descripcion;
      activo = categoria.activo;
    }
  }

  @override
  void dispose() {
    controladorNombre.dispose();
    controladorDescripcion.dispose();
    super.dispose();
  }

  void guardarCategoria() {
    if (!claveFormulario.currentState!.validate()) {
      return;
    }

    final categoria = Categoria(
      id: widget.categoria?.id ?? '',
      nombre: controladorNombre.text.trim(),
      descripcion: controladorDescripcion.text.trim(),
      activo: activo,
    );

    Navigator.pop(context, categoria);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.categoria == null ? 'Nueva categoría' : 'Editar categoría',
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: claveFormulario,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controladorNombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingrese el nombre de la categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorDescripcion,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Categoría activa'),
                  subtitle: const Text('Disponible para utilizar en productos'),
                  value: activo,
                  onChanged: (valor) {
                    setState(() {
                      activo = valor;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: guardarCategoria,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar categoría'),
        ),
      ],
    );
  }
}
