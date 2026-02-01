import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MediaService {
  static Future<Directory> _ensureDir(String relativeDir) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, relativeDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Guarda cualquier archivo y devuelve RUTA RELATIVA para SQLite
  static Future<String> saveFile({
    required File source,
    required String relativeDir, // ej: 'media/images' o 'media/docs'
    required String fileName,
  }) async {
    final dir = await _ensureDir(relativeDir);
    final dest = File(p.join(dir.path, fileName));
    if (await dest.exists()) {
      await dest.delete();
    }
    await source.copy(dest.path);

    return p.join(relativeDir, fileName); // <- guardar esto en la BDD
  }

  /// Obtiene el File absoluto a partir de la ruta relativa
  static Future<File> getFile(String relativePath) async {
    final base = await getApplicationDocumentsDirectory();
    return File(p.join(base.path, relativePath));
  }

  static Future<void> deleteFile(String relativePath) async {
    final file = await getFile(relativePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
