import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8EAF6),
            ),
            child: SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(icon, width: 20,height: 20,color: const Color(0xFF031952),)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}