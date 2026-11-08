import 'package:flutter/material.dart';

class EmptyHint extends StatelessWidget {
  final String text;
  const EmptyHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}
