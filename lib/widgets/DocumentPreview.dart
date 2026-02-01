import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../services/mediaService.dart';

class DocumentPreview extends StatelessWidget {
  final String? relativePath;
  final String? displayName;
  const DocumentPreview({super.key, required this.relativePath, this.displayName});

  @override
  Widget build(BuildContext context) {
    if (relativePath == null || relativePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final ext = p.extension(relativePath!).toLowerCase();

    return FutureBuilder<File>(
      future: MediaService.getFile(relativePath!),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text("No se pudo cargar el archivo"),
          );
        }

        final file = snap.data!;

        if (['.jpg', '.jpeg', '.png'].contains(ext)) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, height: 180, fit: BoxFit.cover),
            ),
          );
        }

        if (ext == '.pdf') {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(displayName ?? p.basename(file.path), overflow: TextOverflow.ellipsis),
                subtitle: const Text("PDF", maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: "Abrir",
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => OpenFilex.open(file.path),
                    ),
                    IconButton(
                      tooltip: "Compartir / Guardar",
                      icon: const Icon(Icons.share),
                      onPressed: () => Share.shareXFiles([XFile(file.path)]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text("Formato no soportado: $ext"),
        );
      },
    );
  }
}
