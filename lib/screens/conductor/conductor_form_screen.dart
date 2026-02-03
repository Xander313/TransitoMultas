import 'package:flutter/material.dart';

import '../../models/ConductorModel.dart';
import '../../repository/ConductorReposiroty.dart';

class ConductorFormScreen extends StatefulWidget {
  const ConductorFormScreen({super.key});

  @override
  State<ConductorFormScreen> createState() => _ConductorFormScreenState();
}

class _ConductorFormScreenState extends State<ConductorFormScreen> {
  final formKey = GlobalKey<FormState>();

  final cedulaController = TextEditingController();
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final numeroLicenciaController = TextEditingController();
  final tipoLicenciaController = TextEditingController();
  final telefonoController = TextEditingController();

  final repo = ConductorRepository();
  ConductorModel? item;

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
      fillColor: const Color.fromRGBO(255, 255, 255, 1),
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
    if (args is ConductorModel) {
      item = args;
      cedulaController.text = item!.cedula;
      nombresController.text = item!.nombres;
      apellidosController.text = item!.apellidos;
      numeroLicenciaController.text = item!.numeroLicencia;
      tipoLicenciaController.text = item!.tipoLicencia;
      telefonoController.text = item!.telefono;
    }
  }

  @override
  void dispose() {
    cedulaController.dispose();
    nombresController.dispose();
    apellidosController.dispose();
    numeroLicenciaController.dispose();
    tipoLicenciaController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = item != null;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),
      appBar: AppBar(
        title: Text(esEditar ? "Editar conductor" : "Insertar conductor"),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: cedulaController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "La cédula es obligatoria";
                  if (v.trim().length < 10) return "Cédula inválida";
                  return null;
                },
                decoration: _decoration(
                  label: "Cédula",
                  hint: "Ej: 0102030405",
                  icon: Icons.badge,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: nombresController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Los nombres son obligatorios";
                  if (v.trim().length > 80) return "Máximo 80 caracteres";
                  return null;
                },
                decoration: _decoration(
                  label: "Nombres",
                  hint: "Ej: Juan Carlos",
                  icon: Icons.person,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: apellidosController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Los apellidos son obligatorios";
                  if (v.trim().length > 80) return "Máximo 80 caracteres";
                  return null;
                },
                decoration: _decoration(
                  label: "Apellidos",
                  hint: "Ej: Pérez López",
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: numeroLicenciaController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "El número de licencia es obligatorio";
                  if (v.trim().length > 30) return "Máximo 30 caracteres";
                  return null;
                },
                decoration: _decoration(
                  label: "Número de licencia",
                  hint: "Ej: ABC-123456",
                  icon: Icons.credit_card,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: tipoLicenciaController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "El tipo de licencia es obligatorio";
                  if (v.trim().length > 10) return "Máximo 10 caracteres";
                  return null;
                },
                decoration: _decoration(
                  label: "Tipo de licencia",
                  hint: "Ej: B",
                  icon: Icons.category,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "El teléfono es obligatorio";
                  if (v.trim().length < 7) return "Teléfono inválido";
                  return null;
                },
                decoration: _decoration(
                  label: "Teléfono",
                  hint: "Ej: 0999999999",
                  icon: Icons.phone,
                ),
              ),
              const SizedBox(height: 20),
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
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final nuevo = ConductorModel(
                          cedula: cedulaController.text.trim(),
                          nombres: nombresController.text.trim(),
                          apellidos: apellidosController.text.trim(),
                          numeroLicencia: numeroLicenciaController.text.trim(),
                          tipoLicencia: tipoLicenciaController.text.trim(),
                          telefono: telefonoController.text.trim(),
                        );

                        if (esEditar) {
                          nuevo.id = item!.id;
                          await repo.update(nuevo);
                        } else {
                          await repo.create(nuevo);
                        }

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
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
      ),
    );
  }
}
