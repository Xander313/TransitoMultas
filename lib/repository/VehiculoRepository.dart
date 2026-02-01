import 'package:sqflite/sqlite_api.dart';

import '../models/VehiculoModel.dart';
import '../settings/DatabaseConnection.dart';

class VehiculoRepository {
  final tableName = "vehiculo";
  final database = DatabaseConnection.instance;

  Future<int> create(VehiculoModel data) async {
    final db = await database.db;
    return db.insert(tableName, data.toMap());
  }

  Future<int> update(VehiculoModel data) async {
    final db = await database.db;
    return db.update(tableName, data.toMap(), where: "id = ?", whereArgs: [data.id]);
  }

  Future<int> delete(int id) async {
    final db = await database.db;
    try {
      return await db.delete(tableName, where: "id = ?", whereArgs: [id]);
    } on DatabaseException catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('foreign key constraint failed')) {
        return 0;
      }
      rethrow;
    }
  }

  Future<List<VehiculoModel>> selectAll() async {
    final db = await database.db;
    final response = await db.query(tableName, orderBy: "id DESC");
    return response.map((e) => VehiculoModel.fromMap(e)).toList();
  }

  Future<VehiculoModel?> selectOne(int id) async {
    final db = await database.db;
    final response = await db.query(tableName, where: "id = ?", whereArgs: [id]);

    if (response.isNotEmpty) {
      return VehiculoModel.fromMap(response.first);
    }

    return null;
  }
}
