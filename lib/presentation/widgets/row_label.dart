import 'package:flutter/material.dart';

class RowLabel extends StatelessWidget {
  const RowLabel({
    super.key,
    required this.onClick,
    required this.title,
  });

  final VoidCallback onClick;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        TextButton(
          onPressed: onClick,
          child: const Text(
            'View All',
            style: TextStyle(
                color: Color(0xFF4A5568),
                fontSize: 14,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}