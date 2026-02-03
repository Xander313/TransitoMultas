import 'package:flutter/material.dart';

import '../../models/TipoInfraccion.dart';
import '../../repository/TipoInfraccionRepository.dart';

class TipoInfraccionFormScreen extends StatefulWidget {
  const TipoInfraccionFormScreen({super.key});

  @override
  State<TipoInfraccionFormScreen> createState() => _TipoInfraccionFormScreenState();
}

class _TipoInfraccionFormScreenState extends State<TipoInfraccionFormScreen> {
  final formKey = GlobalKey<FormState>();

  final codigoController = TextEditingController();
  final descripcionController = TextEditingController();
  final montoBaseController = TextEditingController();
  final puntosLicenciaController = TextEditingController();

  final repository = TipoInfraccionRepository();

  String gravedadSeleccionada = 'LEVE';
  TipoInfraccionModel? item;

  final List<String> gravedadOptions = ['LEVE', 'MEDIA', 'GRAVE'];

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color.fromRGBO(226, 232, 240, 1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color.fromRGBO(0, 66, 137, 1),
          width: 2,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      item = args['tipo'] as TipoInfraccionModel?;
      final viewOnly = args['viewOnly'] as bool? ?? false;
      
      if (item != null) {
        codigoController.text = item!.codigo;
        descripcionController.text = item!.descripcion;
        gravedadSeleccionada = item!.gravedad;
        montoBaseController.text = item!.montoBase.toString();
        puntosLicenciaController.text = item!.puntosLicencia.toString();
      }
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    descripcionController.dispose();
    montoBaseController.dispose();
    puntosLicenciaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!formKey.currentState!.validate()) return;

    final nuevo = TipoInfraccionModel(
      id: item?.id,
      codigo: codigoController.text.trim(),
      descripcion: descripcionController.text.trim(),
      gravedad: gravedadSeleccionada,
      montoBase: double.parse(montoBaseController.text.trim()),
      puntosLicencia: int.parse(puntosLicenciaController.text.trim()),
    );

    try {
      if (item == null) {
        await repository.create(nuevo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de infracción creado')),
        );
      } else {
        await repository.update(nuevo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de infracción actualizado')),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = item != null;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final viewOnly = args?['viewOnly'] as bool? ?? false;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),
      appBar: AppBar(
        title: Text(viewOnly ? "Ver Tipo de Infracción" : 
                   esEditar ? "Editar Tipo de Infracción" : "Nuevo Tipo de Infracción"),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: codigoController,
              readOnly: viewOnly,
              validator: (v) => v == null || v.trim().isEmpty
                  ? "El campo es requerido"
                  : null,
              decoration: _decoration(
                label: "Código",
                hint: "Ej: A01, B12, C07",
                icon: Icons.code,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: descripcionController,
              readOnly: viewOnly,
              maxLines: 3,
              validator: (v) => v == null || v.trim().isEmpty
                  ? "El campo es requerido"
                  : null,
              decoration: _decoration(
                label: "Descripción",
                hint: "Ingrese la descripción de la infracción",
                icon: Icons.description,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: gravedadSeleccionada,
              decoration: InputDecoration(
                labelText: "Gravedad",
                hintText: "Seleccione la gravedad",
                prefixIcon: const Icon(Icons.warning),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color.fromRGBO(226, 232, 240, 1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(0, 66, 137, 1),
                    width: 2,
                  ),
                ),
              ),
              items: gravedadOptions
                  .map(
                    (g) => DropdownMenuItem<String>(
                      value: g,
                      child: Text(g),
                    ),
                  )
                  .toList(),
              onChanged: viewOnly ? null : (v) {
                if (v != null) {
                  setState(() => gravedadSeleccionada = v);
                }
              },
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Seleccione la gravedad";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: montoBaseController,
              readOnly: viewOnly,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "El campo es requerido";
                if (double.tryParse(v.trim()) == null) return "Ingrese un monto válido";
                return null;
              },
              decoration: _decoration(
                label: "Monto Base",
                hint: "Ej: 150.00",
                icon: Icons.monetization_on,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: puntosLicenciaController,
              readOnly: viewOnly,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "El campo es requerido";
                if (int.tryParse(v.trim()) == null) return "Ingrese un número válido";
                return null;
              },
              decoration: _decoration(
                label: "Puntos en Licencia",
                hint: "Ej: 5, 10, 15",
                icon: Icons.score,
              ),
            ),
            const SizedBox(height: 20),
            if (!viewOnly)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(220, 38, 38, 1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel),
                          SizedBox(width: 10),
                          Text("Cancelar"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextButton(
                      onPressed: _guardar,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: esEditar
                            ? const Color.fromRGBO(245, 158, 11, 1)
                            : const Color.fromRGBO(0, 66, 137, 1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(esEditar ? Icons.edit : Icons.save),
                          const SizedBox(width: 10),
                          Text(esEditar ? "Editar" : "Guardar"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}