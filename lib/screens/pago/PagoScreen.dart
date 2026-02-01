import 'package:flutter/material.dart';

import '../../models/PagoModel.dart';
import '../../repository/PagoRepository.dart';

class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final PagoRepository repo = PagoRepository();

  List<PagoModel> items = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarItems();
  }

  Future<void> cargarItems() async {
    setState(() => cargando = true);
    items = await repo.selectAll();
    if (!mounted) return;
    setState(() => cargando = false);
  }

  Color _metodoBg(String metodo) {
    final m = metodo.toUpperCase();
    if (m == 'EFECTIVO') return const Color.fromRGBO(219, 234, 254, 1); // azul suave
    if (m == 'TARJETA') return const Color.fromRGBO(254, 243, 199, 1); // ámbar suave
    return const Color.fromRGBO(220, 252, 231, 1); // transferencia -> verde suave
  }

  Color _metodoFg(String metodo) {
    final m = metodo.toUpperCase();
    if (m == 'EFECTIVO') return const Color.fromRGBO(30, 64, 175, 1); // azul
    if (m == 'TARJETA') return const Color.fromRGBO(146, 64, 14, 1); // ámbar oscuro
    return const Color.fromRGBO(22, 101, 52, 1); // verde oscuro
  }

  void eliminarItem(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Seguro que desea eliminar este pago?"),
        content: Text(
          "ID Pago: $id\n\n"
          "Al eliminar el pago, la multa asociada volverá a estado PENDIENTE.",
        ),

        actions: [
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final int res = await repo.delete(id);

              Navigator.pop(context);
              if (!mounted) return;

              if (res > 0) {
                messenger.showSnackBar(
                  const SnackBar(content: Text("Pago eliminado correctamente")),
                );
                await cargarItems();
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("No se puede eliminar: hay referencias en otros registros."),
                  ),
                );
              }
            },
            child: const Text("Sí"),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),

      appBar: AppBar(
        title: const Text("Listado de Pagos"),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("No existen registros"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color.fromRGBO(229, 231, 235, 1), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

                    title: Text(
                      "Pago: \$${item.montoPagado.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(17, 24, 39, 1),
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fecha: ${item.fechaPago}",
                            style: const TextStyle(color: Color.fromRGBO(107, 114, 128, 1)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Multa ID: ${item.idMulta}",
                            style: const TextStyle(color: Color.fromRGBO(107, 114, 128, 1)),
                          ),
                          const SizedBox(height: 8),

                          // Badge método
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _metodoBg(item.metodoPago),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.metodoPago.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _metodoFg(item.metodoPago),
                                ),
                              ),
                            ),
                          ),

                          // Indicador si hay comprobante
                          if (item.comprobantePath != null &&
                              item.comprobantePath!.trim().isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attachment,
                                    size: 18,
                                    color: Color.fromRGBO(107, 114, 128, 1),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Comprobante adjunto",
                                    style: TextStyle(color: Color.fromRGBO(107, 114, 128, 1)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/pago/form', arguments: item);
                            cargarItems();
                          },
                          icon: const Icon(Icons.edit, color: Color.fromRGBO(245, 158, 11, 1)),
                        ),
                        IconButton(
                          onPressed: () => eliminarItem(item.id as int),
                          icon: const Icon(Icons.delete, color: Color.fromRGBO(220, 38, 38, 1)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.pushNamed(context, '/pago/form');
          cargarItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
