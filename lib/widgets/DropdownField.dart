import 'package:flutter/material.dart';

class DropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final String hint;
  final IconData icon;
  final FormFieldValidator<T>? validator;
  final ValueChanged<T?> onChanged;

  const DropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.icon = Icons.arrow_drop_down,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
