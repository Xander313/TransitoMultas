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
      'id_conductor': id,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'numero_licencia': numeroLicencia,
      'tipo_licencia': tipoLicencia,
      'telefono': telefono,
    };
  }

  // Convertir desde SQLite
  factory ConductorModel.fromMap(Map<String, dynamic> data) {
    return ConductorModel(
      id: data['id_conductor'] as int?,
      cedula: (data['cedula'] ?? '').toString(),
      nombres: (data['nombres'] ?? '').toString(),
      apellidos: (data['apellidos'] ?? '').toString(),
      numeroLicencia: (data['numero_licencia'] ?? '').toString(),
      tipoLicencia: (data['tipo_licencia'] ?? '').toString(),
      telefono: (data['telefono'] ?? '').toString(),
    );
  }
}
