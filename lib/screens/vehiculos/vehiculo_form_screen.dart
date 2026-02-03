import 'package:flutter/material.dart';

import '../../models/ConductorModel.dart';
import '../../models/VehiculoModel.dart';
import '../../repository/ConductorReposiroty.dart';
import '../../repository/VehiculoRepository.dart';

class VehiculoFormsScreen extends StatefulWidget {
  const VehiculoFormsScreen({super.key});

  @override
  State<VehiculoFormsScreen> createState() => _VehiculoFormsScreenState();
}

class _VehiculoFormsScreenState extends State<VehiculoFormsScreen> {
  final formVehiculo = GlobalKey<FormState>();

  final placaController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final colorController = TextEditingController();
  final anioController = TextEditingController();

  final conductorRepo = ConductorRepository();
  final repoVehiculo = VehiculoRepository();

  int? conductorSeleccionadoId;
  List<ConductorModel> conductores = [];

  VehiculoModel? vehiculo;

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
  void initState() {
    super.initState();
    _cargarConductores();
  }

  Future<void> _cargarConductores() async {
    final data = await conductorRepo.selectAll();
    if (!mounted) return;
    setState(() {
      conductores = data;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is VehiculoModel) {
      vehiculo = args;
      placaController.text = vehiculo!.placa;
      marcaController.text = vehiculo!.marca;
      modeloController.text = vehiculo!.modelo;
      colorController.text = vehiculo!.color;
      anioController.text = vehiculo!.anio.toString();
      conductorSeleccionadoId = vehiculo!.idConductor;
    }
  }

  @override
  void dispose() {
    placaController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    colorController.dispose();
    anioController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!formVehiculo.currentState!.validate()) return;

    final nuevo = VehiculoModel(
      placa: placaController.text.trim(),
      marca: marcaController.text.trim(),
      modelo: modeloController.text.trim(),
      color: colorController.text.trim(),
      anio: int.parse(anioController.text.trim()),
      idConductor: conductorSeleccionadoId!,
    );

    if (vehiculo != null) {
      nuevo.id = vehiculo!.id;
      await repoVehiculo.update(nuevo);
    } else {
      await repoVehiculo.create(nuevo);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = vehiculo != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),
      appBar: AppBar(
        title: Text(esEditar ? "Editar Vehículo" : "Insertar Vehículo"),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formVehiculo,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: placaController,
              validator: (v) => v == null || v.trim().isEmpty
                  ? "El campo es requerido"
                  : null,
              decoration: _decoration(
                label: "Placa",
                hint: "Ingrese la placa del vehículo",
                icon: Icons.qr_code,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: marcaController,
              validator: (v) => v == null || v.trim().isEmpty
                  ? "El campo es requerido"
                  : null,
              decoration: _decoration(
                label: "Marca",
                hint: "Ingrese la marca del vehículo",
                icon: Icons.abc,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: modeloController,
              validator: (v) => v == null || v.trim().isEmpty
                  ? "El campo es requerido"
                  : null,
              decoration: _decoration(
                label: "Modelo",
                hint: "Ingrese el modelo del vehículo",
                icon: Icons.list,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: colorController,
              validator: (v) => v == null || v.trim().isEmpty
                  ? "El campo es requerido"
                  : null,
              decoration: _decoration(
                label: "Color",
                hint: "Ingrese el color del vehículo",
                icon: Icons.color_lens,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: anioController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "El campo es requerido";
                if (int.tryParse(v.trim()) == null) return "Ingrese un año válido";
                return null;
              },
              decoration: _decoration(
                label: "Año",
                hint: "Ingrese el año del vehículo",
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: conductorSeleccionadoId,
              validator: (v) => v == null ? "Seleccione un conductor" : null,
              decoration: _decoration(
                label: "Conductor",
                hint: "Seleccione un conductor",
                icon: Icons.person,
              ),
              items: conductores
                  .where((c) => c.id != null)
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.id!,
                      child: Text("${c.nombres} ${c.apellidos}"),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => conductorSeleccionadoId = v),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
              const SizedBox(width: 16),
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
        ),
      ),
    );
  }
}
