class PagoModel {
  int? id;
  String fechaPago;
  double montoPagado;
  String metodoPago;
  int idMulta;
  String? comprobantePath;

  PagoModel({
    this.id,
    required this.fechaPago,
    required this.montoPagado,
    required this.metodoPago,
    required this.idMulta,
    this.comprobantePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fechaPago': fechaPago,
      'montoPagado': montoPagado,
      'metodoPago': metodoPago,
      'idMulta': idMulta,
      'comprobantePath': comprobantePath,
    };
  }

  factory PagoModel.fromMap(Map<String, dynamic> data) {
    return PagoModel(
      id: data['id'] as int?,
      fechaPago: (data['fechaPago'] ?? '').toString(),
      montoPagado: data['montoPagado'] is int
          ? (data['montoPagado'] as int).toDouble()
          : (data['montoPagado'] as num).toDouble(),
      metodoPago: (data['metodoPago'] ?? '').toString(),
      idMulta: (data['idMulta'] as num).toInt(),
      comprobantePath: data['comprobantePath']?.toString(),
    );
  }
}
