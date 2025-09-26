import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  final String text;
  final TextAlign align;

  const AppLabel(this.text, {super.key, required this.align});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        textAlign: align,
      ),
    );
  }
}
