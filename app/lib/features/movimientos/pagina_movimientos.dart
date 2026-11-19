import 'package:flutter/material.dart';
import 'modelo_movimiento_inventario.dart';
import 'servicio_movimientos.dart';
import 'formulario_entrada.dart';
import 'formulario_salida.dart';
import 'formulario_transferencia.dart';

class PaginaMovimientos extends StatefulWidget {
  const PaginaMovimientos({super.key});

  @override
  State<PaginaMovimientos> createState() =>
      _PaginaMovimientosState();
}

class _PaginaMovimientosState extends State<PaginaMovimientos> {
  final ServicioMovimientos _servicio = ServicioMovimientos();

  List<MovimientoInventario> _movimientos = [];
  bool _cargando = true;
  String? _error;
  String _tipo = '';
  int _pagina = 1;

  @override
  void initState() {
    super.initState();
    _cargarMovimientos();
  }

  Future<void> _cargarMovimientos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final movimientos = await _servicio.obtenerMovimientos(
        pagina: _pagina,
        tipo: _tipo.isEmpty ? null : _tipo,
      );

      if (!mounted) return;

      setState(() {
        _movimientos = movimientos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _abrirFormularioEntrada() async {
  final registrado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const FormularioEntrada(),
  );

  if (!mounted || registrado != true) return;

  _pagina = 1;
  await _cargarMovimientos();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Entrada de inventario registrada correctamente.'),
    ),
  );
}

  String _fecha(DateTime? fecha) {
    if (fecha == null) return '-';

    final local = fecha.toLocal();

    String dos(int valor) => valor.toString().padLeft(2, '0');

    return '${dos(local.day)}/${dos(local.month)}/${local.year} '
        '${dos(local.hour)}:${dos(local.minute)}';
  }

  Future<void> _abrirFormularioSalida() async {
  final registrado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const FormularioSalida(),
  );

  if (!mounted || registrado != true) return;

  _pagina = 1;
  await _cargarMovimientos();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Salida de inventario registrada correctamente.'),
    ),
  );
}

Future<void> _abrirFormularioTransferencia() async {
  final registrado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const FormularioTransferencia(),
  );

  if (!mounted || registrado != true) return;

  _pagina = 1;
  await _cargarMovimientos();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Transferencia registrada correctamente.',
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movimientos de Inventario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Historial de entradas, salidas y transferencias.',
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de movimiento',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: 'entrada',
                      child: Text('Entradas'),
                    ),
                    DropdownMenuItem(
                      value: 'salida',
                      child: Text('Salidas'),
                    ),
                    DropdownMenuItem(
                      value: 'transferencia',
                      child: Text('Transferencias'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor == null) return;
                    _tipo = valor;
                    _pagina = 1;
                    _cargarMovimientos();
                  },
                ),
              ),
              OutlinedButton.icon(
                onPressed: _cargando ? null : _cargarMovimientos,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),

              FilledButton.icon(
                onPressed: _abrirFormularioEntrada,
                icon: const Icon(Icons.add),
                label: const Text('Registrar entrada'),
              ),
              FilledButton.icon(
                onPressed: _abrirFormularioSalida,
                icon: const Icon(Icons.add),
                label: const Text('Registrar salida'),
              ),
              FilledButton.icon(
                onPressed: _abrirFormularioTransferencia,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Registrar transferencia'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _movimientos.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay movimientos registrados.',
                            ),
                          )
                        : SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Fecha')),
                                  DataColumn(label: Text('Producto')),
                                  DataColumn(label: Text('Tipo')),
                                  DataColumn(label: Text('Cantidad')),
                                  DataColumn(label: Text('Origen')),
                                  DataColumn(label: Text('Destino')),
                                  DataColumn(label: Text('Referencia')),
                                ],
                                rows: _movimientos.map((movimiento) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${movimiento.id}')),
                                      DataCell(Text(_fecha(movimiento.fecha))),
                                      DataCell(Text(movimiento.nombreProducto)),
                                      DataCell(Text(movimiento.tipo.toUpperCase())),
                                      DataCell(Text('${movimiento.cantidad}')),
                                      DataCell(Text(movimiento.almacenOrigen ?? '-')),
                                      DataCell(Text(movimiento.almacenDestino ?? '-')),
                                      DataCell(Text(movimiento.referencia ?? '-')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Página $_pagina'),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _cargando || _pagina <= 1
                    ? null
                    : () {
                        _pagina--;
                        _cargarMovimientos();
                      },
                child: const Text('Anterior'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _cargando || _movimientos.length < 20
                    ? null
                    : () {
                        _pagina++;
                        _cargarMovimientos();
                      },
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
