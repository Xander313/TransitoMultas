import '../models/TipoInfraccion.dart';
import '../settings/DatabaseConnection.dart';

class TipoInfraccionRepository {
  final tableName = "tipoInfraccion";
  final database = DatabaseConnection.instance;

  Future<int> create(TipoInfraccionModel data) async {
    final db = await database.db;
    return db.insert(tableName, data.toMap());
  }

  Future<int> update(TipoInfraccionModel data) async {
    final db = await database.db;
    return db.update(tableName, data.toMap(), where: "id = ?", whereArgs: [data.id]);
  }

  Future<int> delete(int id) async {
    final db = await database.db;
    return db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<List<TipoInfraccionModel>> selectAll() async {
    final db = await database.db;
    final response = await db.query(tableName);
    return response.map((e) => TipoInfraccionModel.fromMap(e)).toList();
  }

  Future<TipoInfraccionModel?> selectOne(int id) async {
    final db = await database.db;
    final response = await db.query(tableName, where: "id = ?", whereArgs: [id]);

    if (response.isNotEmpty) {
      return TipoInfraccionModel.fromMap(response.first);
    }

    return null;
  }
}
