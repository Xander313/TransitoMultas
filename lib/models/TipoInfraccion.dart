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

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_tipo_infraccion': id,
      'codigo': codigo,
      'descripcion': descripcion,
      'gravedad': gravedad,
      'monto_base': montoBase,
      'puntos_licencia': puntosLicencia,
    };
  }

  // Convertir desde SQLite
  factory TipoInfraccionModel.fromMap(Map<String, dynamic> data) {
    return TipoInfraccionModel(
      id: data['id_tipo_infraccion'] as int?,
      codigo: (data['codigo'] ?? '').toString(),
      descripcion: (data['descripcion'] ?? '').toString(),
      gravedad: (data['gravedad'] ?? '').toString(),
      montoBase: data['monto_base'] is int
          ? (data['monto_base'] as int).toDouble()
          : (data['monto_base'] as num).toDouble(),
      puntosLicencia: (data['puntos_licencia'] as num).toInt(),
    );
  }
}
