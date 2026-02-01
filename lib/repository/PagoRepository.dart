import '../models/PagoModel.dart';
import '../settings/DatabaseConnection.dart';

class PagoRepository {
  final tableName = "pago";
  final database = DatabaseConnection.instance;

  Future<int> create(PagoModel data) async {
    final db = await database.db;
    return db.insert(tableName, data.toMap());
  }

  Future<int> update(PagoModel data) async {
    final db = await database.db;
    return db.update(tableName, data.toMap(), where: "id = ?", whereArgs: [data.id]);
  }

  Future<int> delete(int id) async {
    final db = await database.db;
    return db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<List<PagoModel>> selectAll() async {
    final db = await database.db;
    final response = await db.query(tableName);
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
