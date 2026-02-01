import 'package:sqflite/sqlite_api.dart';

import '../models/MultaModel.dart';
import '../settings/DatabaseConnection.dart';

class MultaRepository {
  final tableName = "multa";
  final database = DatabaseConnection.instance;

  Future<int> create(MultaModel data) async {
    final db = await database.db;
    return db.insert(tableName, data.toMap());
  }

  Future<int> update(MultaModel data) async {
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

  Future<List<MultaModel>> selectAll() async {
    final db = await database.db;
    final response = await db.query(tableName, orderBy: "id DESC");
    return response.map((e) => MultaModel.fromMap(e)).toList();
  }

  Future<List<MultaModel>> selectPendientes() async {
    final db = await database.db;
    final response = await db.query(
      tableName,
      where: "estado = ?",
      whereArgs: ["PENDIENTE"],
      orderBy: "id DESC",
    );
    return response.map((e) => MultaModel.fromMap(e)).toList();
  }

  Future<MultaModel?> selectOne(int id) async {
    final db = await database.db;
    final response = await db.query(tableName, where: "id = ?", whereArgs: [id]);

    if (response.isNotEmpty) {
      return MultaModel.fromMap(response.first);
    }

    return null;
  }
}
