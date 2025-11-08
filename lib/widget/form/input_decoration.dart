import 'package:flutter/material.dart';

InputDecoration appInputDecoration({
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? label,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4E46B4), width: 1.2),
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
  );
}
