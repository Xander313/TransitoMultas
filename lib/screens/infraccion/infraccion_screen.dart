import 'package:flutter/material.dart';

import '../../repository/TipoInfraccionRepository.dart';
import '../../models/TipoInfraccion.dart';

class TipoInfraccionScreen extends StatefulWidget {
  const TipoInfraccionScreen({super.key});

  @override
  State<TipoInfraccionScreen> createState() => _TipoInfraccionScreenState();
}

class _TipoInfraccionScreenState extends State<TipoInfraccionScreen> {
  final TipoInfraccionRepository _repository = TipoInfraccionRepository();
  List<TipoInfraccionModel> _tipos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _repository.selectAll();
    setState(() {
      _tipos = data;
    });
  }

  Future<void> _delete(int id) async {
    final result = await _repository.delete(id);
    
    if (result > 0) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipo de infracción eliminado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede eliminar, existen multas relacionadas')),
      );
    }
  }

  void _showDeleteDialog(TipoInfraccionModel tipo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar tipo de infracción ${tipo.codigo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _delete(tipo.id!);
            },
            child: const Text('Eliminar'),
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
        title: const Text('Tipos de Infracción'),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),
      body: _tipos.isEmpty
          ? const Center(child: Text('No hay tipos de infracción registrados'))
          : ListView.builder(
              itemCount: _tipos.length,
              itemBuilder: (context, index) {
                final tipo = _tipos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(tipo.codigo),
                    subtitle: Text(tipo.descripcion),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/tipoInfraccion/form',
                              arguments: {'tipo': tipo},
                            ).then((_) => _loadData()); // ✅ Esto ya está bien
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _showDeleteDialog(tipo),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/tipoInfraccion/form',
                        arguments: {'tipo': tipo, 'viewOnly': true},
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/tipoInfraccion/form')
              .then((_) => _loadData()); // ✅ ¡Agrega esto!
        },
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}