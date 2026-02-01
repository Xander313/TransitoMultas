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

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_vehiculo': id,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'anio': anio,
      'id_conductor': idConductor,
    };
  }

  // Convertir desde SQLite
  factory VehiculoModel.fromMap(Map<String, dynamic> data) {
    return VehiculoModel(
      id: data['id_vehiculo'] as int?,
      placa: (data['placa'] ?? '').toString(),
      marca: (data['marca'] ?? '').toString(),
      modelo: (data['modelo'] ?? '').toString(),
      color: (data['color'] ?? '').toString(),
      anio: (data['anio'] as num).toInt(),
      idConductor: (data['id_conductor'] as num).toInt(),
    );
  }
}
