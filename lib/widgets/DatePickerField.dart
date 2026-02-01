import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final String helpText;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<DateTime> onChanged;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.helpText,
    required this.onChanged,
    this.icon = Icons.date_range,
    this.validator,
  });

  String _fmt(DateTime? d) {
    if (d == null) return "";
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
    );

    if (picked != null) {
      controller.text = _fmt(picked);
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.text = _fmt(value);

    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pick(context),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(icon: Icon(icon), onPressed: () => _pick(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
