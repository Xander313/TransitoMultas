import 'package:flutter/material.dart';

import '../../models/VehiculoModel.dart';
import '../../repository/VehiculoRepository.dart';

class VehiculoScreen extends StatefulWidget {
  const VehiculoScreen({super.key});

  @override
  State<VehiculoScreen> createState() => _VehiculoScreenState();
}

class _VehiculoScreenState extends State<VehiculoScreen> {
  final VehiculoRepository repo = VehiculoRepository();
  bool cargando = true;
  List<VehiculoModel> vehiculos = [];

  @override
  void initState() {
    super.initState();
    cargarVehiculos();
  }

  Future<void> cargarVehiculos() async {
    setState(() => cargando = true);
    vehiculos = await repo.selectAll();
    if (!mounted) return;
    setState(() => cargando = false);
  }

  void eliminarVehiculo(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar vehículo"),
        content: const Text("¿Estás seguro que deseas eliminar este registro?"),
        actions: [
          TextButton(
            onPressed: () async {
              await repo.delete(id);
              if (!mounted) return;
              Navigator.pop(context);
              cargarVehiculos();
            },
            child: const Text("Sí"),
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
        title: const Text("Listado Vehículos"),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : vehiculos.isEmpty
              ? const Center(child: Text("No existen Vehículos"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vehiculos.length,
                  itemBuilder: (context, i) {
                    final v = vehiculos[i];
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
                          "${v.placa} - ${v.marca}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color.fromRGBO(17, 24, 39, 1),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "${v.modelo} | ${v.color} | ${v.anio}",
                            style: const TextStyle(
                              color: Color.fromRGBO(107, 114, 128, 1),
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/vehiculo/form',
                                  arguments: v,
                                );
                                cargarVehiculos();
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Color.fromRGBO(245, 158, 11, 1),
                              ),
                            ),
                            IconButton(
                              onPressed: () => eliminarVehiculo(v.id!),
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
        onPressed: () async {
          await Navigator.pushNamed(context, '/vehiculo/form');
          cargarVehiculos();
        },
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
