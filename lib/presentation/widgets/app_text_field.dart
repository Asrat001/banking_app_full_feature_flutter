import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final IconData? suffixIcon;
  final bool obscureText;
  final int errorMaxLines ;
  final TextInputType keyboardType ;
  final VoidCallback? onSuffixTap;
  final List<TextInputFormatter>? textInputFormatter;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
    this.errorMaxLines=1,
    this.textInputFormatter
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      inputFormatters:textInputFormatter,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        filled: false,
        errorMaxLines:errorMaxLines ,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4A5568), width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
          onTap: onSuffixTap,
          child: Icon(suffixIcon, size: 22, color: Colors.grey[400]),
        )
            : null,
      ),
      validator: validator,
    );
  }
}
