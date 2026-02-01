class TipoInfraccionModel {
  int? id;
  String codigo;
  String descripcion;
  String gravedad;
  double montoBase;
  int puntosLicencia;

  TipoInfraccionModel({
    this.id,
    required this.codigo,
    required this.descripcion,
    required this.gravedad,
    required this.montoBase,
    required this.puntosLicencia,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'descripcion': descripcion,
      'gravedad': gravedad,
      'montoBase': montoBase,
      'puntosLicencia': puntosLicencia,
    };
  }

  factory TipoInfraccionModel.fromMap(Map<String, dynamic> data) {
    return TipoInfraccionModel(
      id: data['id'] as int?,
      codigo: (data['codigo'] ?? '').toString(),
      descripcion: (data['descripcion'] ?? '').toString(),
      gravedad: (data['gravedad'] ?? '').toString(),
      montoBase: data['montoBase'] is int
          ? (data['montoBase'] as int).toDouble()
          : (data['montoBase'] as num).toDouble(),
      puntosLicencia: (data['puntosLicencia'] as num).toInt(),
    );
  }
}
