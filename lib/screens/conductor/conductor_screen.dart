import 'package:flutter/material.dart';

import '../../models/ConductorModel.dart';
import '../../repository/ConductorReposiroty.dart';

class ConductorScreen extends StatefulWidget {
  const ConductorScreen({super.key});

  @override
  State<ConductorScreen> createState() => _ConductorScreenState();
}

class _ConductorScreenState extends State<ConductorScreen> {
  final ConductorRepository repo = ConductorRepository();

  List<ConductorModel> items = [];
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

  void eliminarItem(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar conductor"),
        content: const Text("¿Estás seguro que deseas eliminar este registro?"),
        actions: [
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final res = await repo.delete(id);
              Navigator.pop(context);
              if (!mounted) return;

              if (res > 0) {
                messenger.showSnackBar(
                  const SnackBar(content: Text("Conductor eliminado correctamente")),
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
            child: const Text("Si"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),
      appBar: AppBar(
        title: const Text("Listado de Conductores"),
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
                    final c = items[i];

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Color.fromRGBO(229, 231, 235, 1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        title: Text(
                          "${c.nombres} ${c.apellidos}",
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
                                "Cédula: ${c.cedula}",
                                style: const TextStyle(
                                  color: Color.fromRGBO(107, 114, 128, 1),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Licencia: ${c.tipoLicencia} - ${c.numeroLicencia}",
                                style: const TextStyle(
                                  color: Color.fromRGBO(107, 114, 128, 1),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Teléfono: ${c.telefono}",
                                style: const TextStyle(
                                  color: Color.fromRGBO(107, 114, 128, 1),
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
                                await Navigator.pushNamed(
                                  context,
                                  '/conductor/form',
                                  arguments: c,
                                );
                                cargarItems();
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Color.fromRGBO(245, 158, 11, 1),
                              ),
                            ),
                            IconButton(
                              onPressed: () => eliminarItem(c.id as int),
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromRGBO(220, 38, 38, 1),
                              ),
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
          await Navigator.pushNamed(context, '/conductor/form');
          cargarItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
