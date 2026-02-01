import '../models/PagoModel.dart';
import '../settings/DatabaseConnection.dart';

class PagoRepository {
  final tableName = "pago";
  final database = DatabaseConnection.instance;

  Future<int> create(PagoModel data) async {
    final db = await database.db;

    return await db.transaction((txn) async {
      final pagoId = await txn.insert(tableName, data.toMap());

      // Marcar multa como PAGADA
      final updated = await txn.update(
        "multa",
        {"estado": "PAGADA"},
        where: "id = ?",
        whereArgs: [data.idMulta],
      );

      if (updated == 0) {
        throw Exception("No existe la multa con id=${data.idMulta}");
      }

      return pagoId;
    });
  }

  Future<int> update(PagoModel data) async {
    final db = await database.db;

    return await db.transaction((txn) async {
      // 1) Obtener el idMulta anterior del pago (antes de editar)
      final oldRows = await txn.query(
        tableName,
        columns: ['idMulta'],
        where: "id = ?",
        whereArgs: [data.id],
        limit: 1,
      );

      if (oldRows.isEmpty) {
        throw Exception("Pago no existe (id=${data.id})");
      }

      final oldIdMulta = (oldRows.first['idMulta'] as num).toInt();

      // 2) Actualizar pago (evita intentar actualizar el id)
      final map = data.toMap();
      map.remove('id');

      final res = await txn.update(tableName, map, where: "id = ?", whereArgs: [data.id]);

      // 3) Si cambió la multa, hacer switch de estados
      if (oldIdMulta != data.idMulta) {
        // multa vieja -> PENDIENTE
        await txn.update(
          "multa",
          {"estado": "PENDIENTE"},
          where: "id = ?",
          whereArgs: [oldIdMulta],
        );

        // multa nueva -> PAGADA
        await txn.update("multa", {"estado": "PAGADA"}, where: "id = ?", whereArgs: [data.idMulta]);
      } else {
        // si solo editó monto/ref/etc, garantizar PAGADA
        await txn.update("multa", {"estado": "PAGADA"}, where: "id = ?", whereArgs: [data.idMulta]);
      }

      return res;
    });
  }

  Future<int> delete(int id) async {
    final db = await database.db;

    return await db.transaction((txn) async {
      // buscar a qué multa pertenece este pago
      final rows = await txn.query(
        tableName,
        columns: ['idMulta'],
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );

      if (rows.isEmpty) return 0;

      final idMulta = (rows.first['idMulta'] as num).toInt();

      // borrar el pago
      final res = await txn.delete(tableName, where: "id = ?", whereArgs: [id]);

      // si se borró, volver la multa a PENDIENTE
      if (res > 0) {
        await txn.update("multa", {"estado": "PENDIENTE"}, where: "id = ?", whereArgs: [idMulta]);
      }

      return res;
    });
  }

  Future<List<PagoModel>> selectAll() async {
    final db = await database.db;
    final response = await db.query(tableName, orderBy: "id DESC");
    return response.map((e) => PagoModel.fromMap(e)).toList();
  }

  Future<PagoModel?> selectOne(int id) async {
    final db = await database.db;
    final response = await db.query(tableName, where: "id = ?", whereArgs: [id]);

    if (response.isNotEmpty) {
      return PagoModel.fromMap(response.first);
    }

    return null;
  }
}
