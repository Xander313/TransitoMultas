class VehiculoModel {
  int? id;
  String placa;
  String marca;
  String modelo;
  String color;
  int anio;
  int idConductor;

  VehiculoModel({
    this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.color,
    required this.anio,
    required this.idConductor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'anio': anio,
      'idConductor': idConductor,
    };
  }

  factory VehiculoModel.fromMap(Map<String, dynamic> data) {
    return VehiculoModel(
      id: data['id'] as int?,
      placa: (data['placa'] ?? '').toString(),
      marca: (data['marca'] ?? '').toString(),
      modelo: (data['modelo'] ?? '').toString(),
      color: (data['color'] ?? '').toString(),
      anio: (data['anio'] as num).toInt(),
      idConductor: (data['idConductor'] as num).toInt(),
    );
  }
}
