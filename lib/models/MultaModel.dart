class MultaModel {
  int? id;
  String fechaMulta;
  String lugar;
  double montoFinal;
  String estado;
  int idConductor;
  int idVehiculo;
  int idTipoInfraccion;

  MultaModel({
    this.id,
    required this.fechaMulta,
    required this.lugar,
    required this.montoFinal,
    required this.estado,
    required this.idConductor,
    required this.idVehiculo,
    required this.idTipoInfraccion,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_multa': id,
      'fecha_multa': fechaMulta,
      'lugar': lugar,
      'monto_final': montoFinal,
      'estado': estado,
      'id_conductor': idConductor,
      'id_vehiculo': idVehiculo,
      'id_tipo_infraccion': idTipoInfraccion,
    };
  }

  // Convertir desde SQLite
  factory MultaModel.fromMap(Map<String, dynamic> data) {
    return MultaModel(
      id: data['id_multa'] as int?,
      fechaMulta: (data['fecha_multa'] ?? '').toString(),
      lugar: (data['lugar'] ?? '').toString(),
      montoFinal: data['monto_final'] is int
          ? (data['monto_final'] as int).toDouble()
          : (data['monto_final'] as num).toDouble(),
      estado: (data['estado'] ?? '').toString(),
      idConductor: (data['id_conductor'] as num).toInt(),
      idVehiculo: (data['id_vehiculo'] as num).toInt(),
      idTipoInfraccion: (data['id_tipo_infraccion'] as num).toInt(),
    );
  }
}
