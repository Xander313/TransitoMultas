class PagoModel {
  int? idPago;
  String fechaPago;
  double montoPagado;
  String metodoPago;
  String referencia;
  int idMulta;
  String? comprobantePath;

  PagoModel({
    this.idPago,
    required this.fechaPago,
    required this.montoPagado,
    required this.metodoPago,
    required this.referencia,
    required this.idMulta,
    this.comprobantePath,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_pago': idPago,
      'fecha_pago': fechaPago,
      'monto_pagado': montoPagado,
      'metodo_pago': metodoPago,
      'referencia': referencia,
      'id_multa': idMulta,
      'comprobante_path': comprobantePath,
    };
  }

  // Convertir desde SQLite
  factory PagoModel.fromMap(Map<String, dynamic> data) {
    return PagoModel(
      idPago: data['id_pago'] as int?,
      fechaPago: (data['fecha_pago'] ?? '').toString(),
      montoPagado: data['monto_pagado'] is int
          ? (data['monto_pagado'] as int).toDouble()
          : (data['monto_pagado'] as num).toDouble(),
      metodoPago: (data['metodo_pago'] ?? '').toString(),
      referencia: (data['referencia'] ?? '').toString(),
      idMulta: (data['id_multa'] as num).toInt(),
      comprobantePath: data['comprobante_path']?.toString(),
    );
  }
}
