import 'package:flutter/material.dart';

import 'modelo_producto.dart';

class FormularioProducto extends StatefulWidget {
  final Producto? producto;

  const FormularioProducto({super.key, this.producto});

  @override
  State<FormularioProducto> createState() => _EstadoFormularioProducto();
}

class _EstadoFormularioProducto extends State<FormularioProducto> {
  final claveFormulario = GlobalKey<FormState>();

  late final TextEditingController controladorNombre;
  late final TextEditingController controladorSku;
  late final TextEditingController controladorCodigoBarras;
  late final TextEditingController controladorCategoria;
  late final TextEditingController controladorPrecio;
  late final TextEditingController controladorExistencia;
  late final TextEditingController controladorExistenciaMinima;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    controladorNombre = TextEditingController(text: producto?.nombre ?? '');
    controladorSku = TextEditingController(text: producto?.sku ?? '');
    controladorCodigoBarras = TextEditingController(
      text: producto?.codigoBarras ?? '',
    );
    controladorCategoria = TextEditingController(
      text: producto?.categoria ?? '',
    );
    controladorPrecio = TextEditingController(
      text: producto?.precio.toString() ?? '',
    );
    controladorExistencia = TextEditingController(
      text: producto?.existencia.toString() ?? '0',
    );
    controladorExistenciaMinima = TextEditingController(
      text: producto?.existenciaMinima.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    controladorNombre.dispose();
    controladorSku.dispose();
    controladorCodigoBarras.dispose();
    controladorCategoria.dispose();
    controladorPrecio.dispose();
    controladorExistencia.dispose();
    controladorExistenciaMinima.dispose();
    super.dispose();
  }

  String? validarObligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? validarPrecio(String? valor) {
    final precio = double.tryParse((valor ?? '').replaceAll(',', '.'));
    if (precio == null || !precio.isFinite || precio < 0) {
      return 'Ingrese un precio válido';
    }
    return null;
  }

  String? validarCantidad(String? valor) {
    final cantidad = int.tryParse(valor ?? '');
    if (cantidad == null || cantidad < 0) {
      return 'Ingrese un número entero igual o mayor que cero';
    }
    return null;
  }

  void guardarProducto() {
    if (!claveFormulario.currentState!.validate()) return;

    final producto = Producto(
      id:
          widget.producto?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: controladorNombre.text.trim(),
      sku: controladorSku.text.trim(),
      codigoBarras: controladorCodigoBarras.text.trim(),
      categoria: controladorCategoria.text.trim(),
      precio: double.parse(controladorPrecio.text.trim().replaceAll(',', '.')),
      existencia: int.parse(controladorExistencia.text.trim()),
      existenciaMinima: int.parse(controladorExistenciaMinima.text.trim()),
    );

    Navigator.of(context).pop(producto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.producto == null ? 'Nuevo producto' : 'Editar producto',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: claveFormulario,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: controladorNombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    border: OutlineInputBorder(),
                  ),
                  validator: validarObligatorio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorSku,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    border: OutlineInputBorder(),
                  ),
                  validator: validarObligatorio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorCodigoBarras,
                  decoration: const InputDecoration(
                    labelText: 'Código de barras',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  validator: validarObligatorio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorPrecio,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: validarPrecio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorExistencia,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Existencia inicial',
                    border: OutlineInputBorder(),
                  ),
                  validator: validarCantidad,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorExistenciaMinima,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Existencia mínima',
                    border: OutlineInputBorder(),
                  ),
                  validator: validarCantidad,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: guardarProducto,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar producto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
