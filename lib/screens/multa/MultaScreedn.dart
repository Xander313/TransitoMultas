import 'package:flutter/material.dart';

import '../../models/MultaModel.dart';
import '../../repository/MultaReposiroty.dart';

class MultaScreen extends StatefulWidget {
  const MultaScreen({super.key});

  @override
  State<MultaScreen> createState() => _MultaScreenState();
}

class _MultaScreenState extends State<MultaScreen> {
  final MultaRepository repo = MultaRepository();

  List<MultaModel> items = [];
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

  Color _estadoBg(String estado) {
    final e = estado.toUpperCase();
    if (e == 'PAGADA') return const Color(0xFFDCFCE7);
    return const Color(0xFFFEF3C7);
  }

  Color _estadoFg(String estado) {
    final e = estado.toUpperCase();
    if (e == 'PAGADA') return const Color.fromRGBO(22, 101, 52, 1);
    return const Color.fromRGBO(146, 64, 14, 1);
  }

  void eliminarItem(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Seguro que desea eliminar esta multa?"),
        content: Text("ID Multa: $id"),
        actions: [
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final int res = await repo.delete(id);

              Navigator.pop(context);
              if (!mounted) return;

              if (res > 0) {
                messenger.showSnackBar(
                  const SnackBar(content: Text("Multa eliminada correctamente")),
                );
                await cargarItems();
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      "No se puede eliminar: hay referencias (pago asociado o relaciones).",
                    ),
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
        title: const Text("Listado de Multasssss"),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

                    title: Text(
                      "Lugar: ${item.lugar}",
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fecha: ${item.fechaMulta}",
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Monto: \$${item.montoFinal.toStringAsFixed(2)}  •  Conductor ID: ${item.idConductor}  •  Vehículo ID: ${item.idVehiculo}",
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _estadoBg(item.estado),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.estado.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _estadoFg(item.estado),
                                ),
                              ),
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
                            await Navigator.pushNamed(context, '/multa/form', arguments: item);
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
        backgroundColor: const Color.fromRGBO(30, 64, 175, 1),
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.pushNamed(context, '/multa/form');
          cargarItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
