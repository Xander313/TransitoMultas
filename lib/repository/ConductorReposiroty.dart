import 'package:sqflite/sqlite_api.dart';

import '../models/ConductorModel.dart';
import '../settings/DatabaseConnection.dart';

class ConductorRepository {
  final tableName = "conductor";
  final database = DatabaseConnection.instance;

  Future<int> create(ConductorModel data) async {
    final db = await database.db;
    return db.insert(tableName, data.toMap());
  }

  Future<int> update(ConductorModel data) async {
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

  Future<List<ConductorModel>> selectAll() async {
    final db = await database.db;
    final response = await db.query(tableName);
    return response.map((e) => ConductorModel.fromMap(e)).toList();
  }

  Future<ConductorModel?> selectOne(int id) async {
    final db = await database.db;
    final response = await db.query(tableName, where: "id = ?", whereArgs: [id]);

    if (response.isNotEmpty) {
      return ConductorModel.fromMap(response.first);
    }

    return null;
  }
}
