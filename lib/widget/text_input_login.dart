import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class TextInputLogin extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String Function(String?)? validator;
  final VoidCallback? onTap;
  final bool isPassword;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Widget? trailing;

  const TextInputLogin({
    super.key,
    this.controller,
    required this.hint,
    this.validator,
    this.onTap,
    this.isPassword = false,
    this.readOnly = false,
    this.keyboardType,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return MoonFormTextInput(
      textInputSize: MoonTextInputSize.xl,
      hasFloatingLabel: true,
      controller: controller,
      hintText: hint,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      keyboardType: keyboardType,
      obscureText: isPassword,
      trailing: trailing,
    );
  }
}
