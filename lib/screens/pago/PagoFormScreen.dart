import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../models/MultaModel.dart';
import '../../models/PagoModel.dart';
import '../../repository/MultaReposiroty.dart';
import '../../repository/PagoRepository.dart';
import '../../services/mediaService.dart';
import '../../widgets/DatePickerField.dart';
import '../../widgets/DocumentPreview.dart';
import '../../widgets/DropdownField.dart';
import '../../widgets/FilePickerField.dart';

class PagoFormScreen extends StatefulWidget {
  const PagoFormScreen({super.key});

  @override
  State<PagoFormScreen> createState() => _PagoFormScreenState();
}

class _PagoFormScreenState extends State<PagoFormScreen> {
  final formKey = GlobalKey<FormState>();

  final fechaPagoController = TextEditingController();
  final montoPagadoController = TextEditingController();
  final referenciaController = TextEditingController();

  DateTime? fechaPagoValue;

  final pagoRepo = PagoRepository();
  final multaRepo = MultaRepository();

  PagoModel? item;

  bool cargando = true;
  bool yaInicializado = false;
  bool guardado = false;

  // Multas
  List<MultaModel> multas = [];
  MultaModel? selectedMulta;

  // Métodos
  final List<String> metodos = const ["EFECTIVO", "TARJETA", "TRANSFERENCIA"];
  String? metodoSeleccionado;

  // Archivo (ruta relativa para SQLite)
  String? comprobantePathActual; // lo que se guardará
  String? comprobantePathOriginal; // lo que venía en edición
  bool borrarOriginalAlGuardar = false;

  int? preselectMultaId; // por si algún día llamas a /pago/form con un id de multa

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (yaInicializado) return;
    yaInicializado = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is PagoModel) {
      item = args;

      fechaPagoController.text = item!.fechaPago;
      montoPagadoController.text = item!.montoPagado.toStringAsFixed(2);
      referenciaController.text = item!.referencia;
      metodoSeleccionado = item!.metodoPago;

      comprobantePathOriginal = item!.comprobantePath;
      comprobantePathActual = item!.comprobantePath;

      final d = DateTime.tryParse(item!.fechaPago);
      if (d != null) fechaPagoValue = d;
    } else {
      // Nuevo (defaults)
      final hoy = DateTime.now();
      fechaPagoValue = hoy;
      fechaPagoController.text = hoy.toIso8601String().substring(0, 10); // YYYY-MM-DD
    }

    // Soporte opcional: si te pasan un int como id de multa
    if (args is int) {
      preselectMultaId = args;
    }

    cargarMultas();
  }

  Future<void> cargarMultas() async {
    setState(() => cargando = true);

    final data = await multaRepo.selectAll();

    // Preselección: edición -> item.idMulta, o si viene id por argumentos
    MultaModel? pre;
    final targetId = item?.idMulta ?? preselectMultaId;

    if (targetId != null) {
      pre = data.firstWhere(
        (m) => m.id == targetId,
        orElse: () => MultaModel(
          id: -1,
          fechaMulta: "",
          lugar: "",
          montoFinal: 0,
          estado: "PENDIENTE",
          idConductor: 0,
          idVehiculo: 0,
          idTipoInfraccion: 0,
        ),
      );
      if (pre.id == -1) pre = null;
    }

    setState(() {
      multas = data;
      selectedMulta = pre;
      cargando = false;
    });

    // Si es nuevo y hay multa seleccionada, autollenar monto con montoFinal
    if (item == null && selectedMulta != null && montoPagadoController.text.trim().isEmpty) {
      montoPagadoController.text = selectedMulta!.montoFinal.toStringAsFixed(2);
    }
  }

  Future<void> _pickComprobante() async {
    // Si ya hay un archivo "nuevo" (temporal) y no es el original, lo borramos para no dejar basura
    if (comprobantePathActual != null &&
        comprobantePathActual!.isNotEmpty &&
        comprobantePathActual != comprobantePathOriginal) {
      await MediaService.deleteFile(comprobantePathActual!);
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    final pickedPath = result.files.single.path;
    if (pickedPath == null || pickedPath.isEmpty) return;

    final src = File(pickedPath);
    final ext = p.extension(pickedPath).toLowerCase();
    final fileName = "pago_${DateTime.now().millisecondsSinceEpoch}$ext";

    final relative = await MediaService.saveFile(
      source: src,
      relativeDir: 'media/pagos',
      fileName: fileName,
    );

    setState(() {
      comprobantePathActual = relative;

      // Si estábamos editando y había un original, marcar para borrar al guardar (reemplazo)
      if (comprobantePathOriginal != null && comprobantePathOriginal!.isNotEmpty) {
        borrarOriginalAlGuardar = true;
      }
    });
  }

  Future<void> _clearComprobante() async {
    // Si el actual es un archivo nuevo temporal, borrarlo ya
    if (comprobantePathActual != null &&
        comprobantePathActual!.isNotEmpty &&
        comprobantePathActual != comprobantePathOriginal) {
      await MediaService.deleteFile(comprobantePathActual!);
    }

    setState(() {
      comprobantePathActual = null;

      // Si había original, marcar para borrar al guardar (el usuario lo quitó)
      if (comprobantePathOriginal != null && comprobantePathOriginal!.isNotEmpty) {
        borrarOriginalAlGuardar = true;
      }
    });
  }

  Future<void> _cleanupTempIfNeeded() async {
    // Si no se guardó y dejamos un archivo nuevo temporal, borrarlo
    if (!guardado &&
        comprobantePathActual != null &&
        comprobantePathActual!.isNotEmpty &&
        comprobantePathActual != comprobantePathOriginal) {
      await MediaService.deleteFile(comprobantePathActual!);
    }
  }

  @override
  void dispose() {
    _cleanupTempIfNeeded();
    fechaPagoController.dispose();
    montoPagadoController.dispose();
    referenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = item != null;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 249, 252, 1),

      appBar: AppBar(
        title: Text(esEditar ? "Editar pago" : "Agregar pago"),
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
                      controller: fechaPagoController,
                      label: "Fecha de pago",
                      hint: "YYYY-MM-DD",
                      value: fechaPagoValue,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      helpText: "Seleccione la fecha del pago",
                      onChanged: (d) => setState(() => fechaPagoValue = d),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "La fecha es obligatoria";
                        final d = DateTime.tryParse(v.trim());
                        if (d == null) return "Fecha inválida";
                        if (d.isAfter(DateTime.now())) return "No puede ser mayor a hoy";
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    DropdownField<MultaModel>(
                      value: selectedMulta,
                      items: multas
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                "ID ${m.id} • ${m.lugar} • \$${m.montoFinal.toStringAsFixed(2)}",
                              ),
                            ),
                          )
                          .toList(),
                      label: "Multa",
                      hint: "Seleccione una multa",
                      icon: Icons.receipt_long,
                      onChanged: (v) {
                        setState(() => selectedMulta = v);
                        if (v != null) {
                          // Autollenar monto (editable)
                          montoPagadoController.text = v.montoFinal.toStringAsFixed(2);
                        }
                      },
                      validator: (v) => v == null ? "Seleccione una multa" : null,
                    ),

                    const SizedBox(height: 14),

                    DropdownField<String>(
                      value: metodoSeleccionado,
                      items: metodos
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      label: "Método de pago",
                      hint: "Seleccione un método",
                      icon: Icons.payments,
                      onChanged: (v) => setState(() => metodoSeleccionado = v),
                      validator: (v) => v == null ? "Seleccione un método" : null,
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: montoPagadoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Monto pagado es obligatorio";
                        final n = double.tryParse(v.trim());
                        if (n == null) return "Debe ser un número";
                        if (n <= 0) return "Debe ser mayor a 0";
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Monto pagado",
                        hintText: "Ej: 40.00",
                        filled: true,
                        fillColor: const Color.fromRGBO(255, 255, 255, 1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: referenciaController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "La referencia es obligatoria";
                        if (v.trim().length > 60) return "Máximo 60 caracteres";
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Referencia",
                        hintText: "Ej: REC-0001",
                        filled: true,
                        fillColor: const Color.fromRGBO(255, 255, 255, 1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Selector de archivo
                    FilePickerField(
                      label: "Comprobante (opcional)",
                      fileName: (comprobantePathActual == null || comprobantePathActual!.isEmpty)
                          ? null
                          : p.basename(comprobantePathActual!),
                      hasFile: (comprobantePathActual != null && comprobantePathActual!.isNotEmpty),
                      onPick: _pickComprobante,
                      onClear: (comprobantePathActual != null && comprobantePathActual!.isNotEmpty)
                          ? _clearComprobante
                          : null,
                    ),

                    // Preview (imagen/pdf)
                    DocumentPreview(
                      relativePath: comprobantePathActual,
                      displayName: (comprobantePathActual == null || comprobantePathActual!.isEmpty)
                          ? null
                          : p.basename(comprobantePathActual!),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await _cleanupTempIfNeeded();
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromRGBO(220, 38, 38, 1),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [Icon(Icons.cancel), SizedBox(width: 10), Text("Cancelar")],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              if (selectedMulta?.id == null) return;
                              if (metodoSeleccionado == null) return;

                              final monto = double.parse(montoPagadoController.text.trim());

                              final nuevo = PagoModel(
                                id: esEditar ? item!.id : null,
                                fechaPago: fechaPagoController.text.trim(),
                                montoPagado: monto,
                                metodoPago: metodoSeleccionado!,
                                referencia: referenciaController.text.trim(),
                                idMulta: selectedMulta!.id!,
                                comprobantePath: comprobantePathActual,
                              );

                              if (esEditar) {
                                await pagoRepo.update(nuevo);
                              } else {
                                await pagoRepo.create(nuevo);
                              }

                              // Si había un comprobante original y el usuario lo reemplazó/quitó, borrarlo solo al guardar
                              if (borrarOriginalAlGuardar &&
                                  comprobantePathOriginal != null &&
                                  comprobantePathOriginal!.isNotEmpty &&
                                  comprobantePathOriginal != comprobantePathActual) {
                                await MediaService.deleteFile(comprobantePathOriginal!);
                              }

                              guardado = true;
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
