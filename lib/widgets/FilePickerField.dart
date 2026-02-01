import 'package:flutter/material.dart';

class FilePickerField extends StatelessWidget {
  final String label;
  final String? fileName;
  final bool hasFile;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const FilePickerField({
    super.key,
    required this.label,
    required this.fileName,
    required this.hasFile,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(fileName ?? "Ningún archivo seleccionado", overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.attach_file),
            label: const Text("Elegir"),
          ),
          if (hasFile)
            IconButton(tooltip: "Quitar", onPressed: onClear, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}
