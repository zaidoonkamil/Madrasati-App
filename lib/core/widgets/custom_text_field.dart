import 'package:flutter/material.dart';

import '../styles/themes.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validate;
  final void Function()? onTap;
  final TextEditingController? controller;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    this.validate,
    required this.hintText,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: appSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorderColor),
      ),
      child: TextFormField(
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: controller,
        maxLines: maxLines,
        validator: validate,
        onTap: onTap,
        style: const TextStyle(
          color: appTextPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: appTextMutedColor,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          prefixIcon:
              prefixIcon == null
                  ? null
                  : Icon(prefixIcon, color: appTextMutedColor, size: 20),
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
