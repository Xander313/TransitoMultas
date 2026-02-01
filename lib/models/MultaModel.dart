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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fechaMulta': fechaMulta,
      'lugar': lugar,
      'montoFinal': montoFinal,
      'estado': estado,
      'idConductor': idConductor,
      'idVehiculo': idVehiculo,
      'idTipoInfraccion': idTipoInfraccion,
    };
  }

  factory MultaModel.fromMap(Map<String, dynamic> data) {
    return MultaModel(
      id: data['id'] as int?,
      fechaMulta: (data['fechaMulta'] ?? '').toString(),
      lugar: (data['lugar'] ?? '').toString(),
      montoFinal: data['montoFinal'] is int
          ? (data['montoFinal'] as int).toDouble()
          : (data['montoFinal'] as num).toDouble(),
      estado: (data['estado'] ?? '').toString(),
      idConductor: (data['idConductor'] as num).toInt(),
      idVehiculo: (data['idVehiculo'] as num).toInt(),
      idTipoInfraccion: (data['idTipoInfraccion'] as num).toInt(),
    );
  }
}
