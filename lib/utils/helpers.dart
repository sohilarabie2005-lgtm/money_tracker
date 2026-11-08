import 'package:flutter/material.dart';

String money(double v) => '\$${v.toStringAsFixed(2)}';

String shortDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

/// "ahmed.ali@mail.com" -> "Ahmed Ali"
String nameFromEmail(String email) {
  final local = email.split('@').first.trim();
  final parts = local
      .split(RegExp(r'[._\-\s]+'))
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase());
  final name = parts.join(' ');
  return name.isEmpty ? 'User' : name;
}

InputDecoration appInputDecoration(String label, IconData icon,
    {Color fill = Colors.white}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: fill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}
