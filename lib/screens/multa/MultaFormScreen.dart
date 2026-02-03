import 'package:flutter/material.dart';

import '../../models/ConductorModel.dart';
import '../../models/MultaModel.dart';
import '../../models/TipoInfraccion.dart';
import '../../models/VehiculoModel.dart';
import '../../repository/ConductorReposiroty.dart';
import '../../repository/MultaReposiroty.dart';
import '../../repository/TipoInfraccionRepository.dart';
import '../../repository/VehiculoRepository.dart';
import '../../widgets/DatePickerField.dart';
import '../../widgets/DropdownField.dart';

class MultaFormScreen extends StatefulWidget {
  const MultaFormScreen({super.key});

  @override
  State<MultaFormScreen> createState() => _MultaFormScreenState();
}

class _MultaFormScreenState extends State<MultaFormScreen> {
  final formKey = GlobalKey<FormState>();

  final marcaController = TextEditingController();
  final placaController = TextEditingController();
  final modeloController = TextEditingController();

  DateTime? fechaMultaValue;

  final multaRepo = MultaRepository();
  final conductorRepo = ConductorRepository();
  final vehiculoRepo = VehiculoRepository();
  final tipoRepo = TipoInfraccionRepository();

  MultaModel? item;

  bool cargando = true;
  bool yaInicializado = false;

  List<ConductorModel> conductores = [];
  ConductorModel? selectedConductor;

  List<VehiculoModel> vehiculosAll = [];
  List<VehiculoModel> vehiculosFiltrados = [];
  VehiculoModel? selectedVehiculo;

  List<TipoInfraccionModel> tipos = [];
  TipoInfraccionModel? selectedTipo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (yaInicializado) return;
    yaInicializado = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MultaModel) {
      item = args;

      final esPagada = item != null && item!.estado.toUpperCase() == "PAGADA";
      if (esPagada) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Multa PAGADA: no se puede editar.")),
          );
        });
      }
      marcaController.text = item!.lugar;
      placaController.text = item!.fechaMulta;

      modeloController.text = item!.montoFinal.toStringAsFixed(2);

      final d = DateTime.tryParse(item!.fechaMulta);
      if (d != null) {
        fechaMultaValue = d;
      }
    } else {
      final hoy = DateTime.now();
      fechaMultaValue = hoy;
      placaController.text = hoy.toIso8601String().substring(0, 10);
    }

    cargarCombos();
  }

  Future<void> cargarCombos() async {
    setState(() => cargando = true);

    final dataConductores = await conductorRepo.selectAll();
    final dataVehiculos = await vehiculoRepo.selectAll();
    final dataTipos = await tipoRepo.selectAll();

    ConductorModel? preCon;
    VehiculoModel? preVeh;
    TipoInfraccionModel? preTipo;

    if (item != null) {
      try {
        preCon = dataConductores.firstWhere((c) => c.id == item!.idConductor);
      } catch (_) {
        preCon = null;
      }

      try {
        preVeh = dataVehiculos.firstWhere((v) => v.id == item!.idVehiculo);
      } catch (_) {
        preVeh = null;
      }

      try {
        preTipo = dataTipos.firstWhere((t) => t.id == item!.idTipoInfraccion);
      } catch (_) {
        preTipo = null;
      }
    }

    if (!mounted) return;

    setState(() {
      conductores = dataConductores;
      vehiculosAll = dataVehiculos;
      tipos = dataTipos;

      selectedConductor = preCon;
      selectedTipo = preTipo;

      vehiculosFiltrados = (selectedConductor?.id != null)
          ? vehiculosAll
                .where((v) => v.idConductor == selectedConductor!.id)
                .toList()
          : vehiculosAll;

      if (preVeh != null && vehiculosFiltrados.any((v) => v.id == preVeh!.id)) {
        selectedVehiculo = preVeh;
      } else {
        selectedVehiculo = null;
      }

      if (selectedTipo != null &&
          (modeloController.text.trim().isEmpty || item == null)) {
        modeloController.text = selectedTipo!.montoBase.toStringAsFixed(2);
      }

      cargando = false;
    });
  }

  void tipoChanged(TipoInfraccionModel? t) {
    setState(() => selectedTipo = t);
    if (t != null) {
      modeloController.text = t.montoBase.toStringAsFixed(2);
    }
  }

  void conductorChanged(ConductorModel? c) {
    setState(() {
      selectedConductor = c;

      vehiculosFiltrados = (c?.id != null)
          ? vehiculosAll.where((v) => v.idConductor == c!.id).toList()
          : vehiculosAll;

      selectedVehiculo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = item != null;
    final esPagada = item != null && item!.estado.toUpperCase() == "PAGADA";

    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),

      appBar: AppBar(
        title: Text(esEditar ? "Editar multa" : "Agregar multa"),
        backgroundColor: const Color.fromRGBO(0, 66, 137, 1),
        foregroundColor: Colors.white,
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    DatePickerField(
                      controller: placaController,
                      label: "Fecha multa",
                      hint: "YYYY-MM-DD",
                      value: fechaMultaValue,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      helpText: "Seleccione la fecha de la multa",
                      onChanged: (d) => setState(() => fechaMultaValue = d),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "La fecha es obligatoria";
                        final d = DateTime.tryParse(v.trim());
                        if (d == null) return "Fecha inválida";
                        if (d.isAfter(DateTime.now()))
                          return "No puede ser mayor a hoy";
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: marcaController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "El lugar es obligatorio";
                        if (v.trim().length > 80) return "Máximo 80 caracteres";
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Lugar",
                        hintText: "Ej: Av. Principal y Calle 10",
                        filled: true,
                        fillColor: const Color.fromRGBO(255, 255, 255, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownField<ConductorModel>(
                      value: selectedConductor,
                      items: conductores
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                "${c.nombres} ${c.apellidos} (${c.cedula})",
                              ),
                            ),
                          )
                          .toList(),
                      label: "Conductor",
                      hint: "Seleccione un conductor",
                      icon: Icons.person,
                      onChanged: conductorChanged,
                      validator: (v) =>
                          v == null ? "Seleccione un conductor" : null,
                    ),

                    const SizedBox(height: 14),

                    DropdownField<VehiculoModel>(
                      value: selectedVehiculo,
                      items: vehiculosFiltrados
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(
                                "${v.placa} - ${v.marca} ${v.modelo}",
                              ),
                            ),
                          )
                          .toList(),
                      label: "Vehículo",
                      hint: selectedConductor == null
                          ? "Seleccione primero un conductor"
                          : "Seleccione un vehículo",
                      icon: Icons.directions_car,
                      onChanged: (v) => setState(() => selectedVehiculo = v),
                      validator: (v) =>
                          v == null ? "Seleccione un vehículo" : null,
                    ),

                    const SizedBox(height: 14),

                    DropdownField<TipoInfraccionModel>(
                      value: selectedTipo,
                      items: tipos
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                "${t.codigo} - ${t.gravedad} (\$${t.montoBase.toStringAsFixed(2)})",
                              ),
                            ),
                          )
                          .toList(),
                      label: "Tipo de infracción",
                      hint: "Seleccione una infracción",
                      icon: Icons.gavel,
                      onChanged: tipoChanged,
                      validator: (v) =>
                          v == null ? "Seleccione un tipo de infracción" : null,
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: modeloController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Monto final es obligatorio";
                        final n = double.tryParse(v.trim());
                        if (n == null) return "Debe ser un número";
                        if (n < 0) return "No puede ser negativo";
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Monto final",
                        hintText: "Ej: 150.00",
                        filled: true,
                        fillColor: const Color.fromRGBO(255, 255, 255, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromRGBO(
                                220,
                                38,
                                38,
                                1,
                              ),
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
                              if (selectedConductor?.id == null) return;
                              if (selectedVehiculo?.id == null) return;
                              if (selectedTipo?.id == null) return;

                              final monto = double.parse(
                                modeloController.text.trim(),
                              );

                              final nuevo = MultaModel(
                                fechaMulta: placaController.text.trim(),
                                lugar: marcaController.text.trim(),
                                montoFinal: monto,
                                estado: "PENDIENTE",
                                idConductor: selectedConductor!.id!,
                                idVehiculo: selectedVehiculo!.id!,
                                idTipoInfraccion: selectedTipo!.id!,
                              );

                              if (esEditar) {
                                if (esPagada) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "No se puede editar una multa PAGADA.",
                                      ),
                                    ),
                                  );
                                  return;
                                } else {
                                  nuevo.id = item!.id;
                                  await multaRepo.update(nuevo);
                                }
                              } else {
                                await multaRepo.create(nuevo);
                              }

                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: esEditar
                                  ? const Color.fromRGBO(
                                      245,
                                      158,
                                      11,
                                      1,
                                    ) // ámbar editar
                                  : const Color.fromRGBO(
                                      0,
                                      66,
                                      137,
                                      1,
                                    ), // azul guardar
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
