class ConductorModel {
  int? id;
  String cedula;
  String nombres;
  String apellidos;
  String numeroLicencia;
  String tipoLicencia;
  String telefono;

  ConductorModel({
    this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.numeroLicencia,
    required this.tipoLicencia,
    required this.telefono,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'numeroLicencia': numeroLicencia,
      'tipoLicencia': tipoLicencia,
      'telefono': telefono,
    };
  }

  // Convertir desde SQLite
  factory ConductorModel.fromMap(Map<String, dynamic> data) {
    return ConductorModel(
      id: data['id'] as int?,
      cedula: (data['cedula'] ?? '').toString(),
      nombres: (data['nombres'] ?? '').toString(),
      apellidos: (data['apellidos'] ?? '').toString(),
      numeroLicencia: (data['numeroLicencia'] ?? '').toString(),
      tipoLicencia: (data['tipoLicencia'] ?? '').toString(),
      telefono: (data['telefono'] ?? '').toString(),
    );
  }
}
