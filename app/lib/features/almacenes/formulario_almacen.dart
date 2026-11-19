import 'package:flutter/material.dart';

import 'modelo_almacen.dart';

class FormularioAlmacen extends StatefulWidget {
  final Almacen? almacen;

  const FormularioAlmacen({super.key, this.almacen});

  @override
  State<FormularioAlmacen> createState() => _EstadoFormularioAlmacen();
}

class _EstadoFormularioAlmacen extends State<FormularioAlmacen> {
  final claveFormulario = GlobalKey<FormState>();

  late final TextEditingController controladorNombre;
  late final TextEditingController controladorCodigo;
  late final TextEditingController controladorUbicacion;
  late final TextEditingController controladorDescripcion;

  bool activo = true;

  bool get editando => widget.almacen != null;

  @override
  void initState() {
    super.initState();

    final almacen = widget.almacen;

    controladorNombre = TextEditingController(text: almacen?.nombre ?? '');
    controladorCodigo = TextEditingController(text: almacen?.codigo ?? '');
    controladorUbicacion = TextEditingController(
      text: almacen?.ubicacion ?? '',
    );
    controladorDescripcion = TextEditingController(
      text: almacen?.descripcion ?? '',
    );

    activo = almacen?.activo ?? true;
  }

  @override
  void dispose() {
    controladorNombre.dispose();
    controladorCodigo.dispose();
    controladorUbicacion.dispose();
    controladorDescripcion.dispose();
    super.dispose();
  }

  void guardarAlmacen() {
    if (!claveFormulario.currentState!.validate()) return;

    final almacen = Almacen(
      id: widget.almacen?.id ?? '',
      nombre: controladorNombre.text.trim(),
      codigo: controladorCodigo.text.trim(),
      ubicacion: controladorUbicacion.text.trim(),
      descripcion: controladorDescripcion.text.trim(),
      activo: activo,
    );

    Navigator.pop(context, almacen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar almacén' : 'Nuevo almacén'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: claveFormulario,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  editando ? 'Editar almacén' : 'Registrar almacén',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: controladorNombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del almacén',
                    prefixIcon: Icon(Icons.warehouse_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el nombre del almacén';
                    }
                    if (valor.trim().length > 150) {
                      return 'Máximo 150 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: controladorCodigo,
                  decoration: const InputDecoration(
                    labelText: 'Código del almacén',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el código del almacén';
                    }
                    if (valor.trim().length > 50) {
                      return 'Máximo 50 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: controladorUbicacion,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: controladorDescripcion,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('Almacén activo'),
                  subtitle: const Text(
                    'Permite habilitar o deshabilitar el almacén',
                  ),
                  value: activo,
                  onChanged: (valor) {
                    setState(() => activo = valor);
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: guardarAlmacen,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        editando ? 'Guardar cambios' : 'Registrar almacén',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
