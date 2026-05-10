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
  final bool readOnly;

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
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      decoration: BoxDecoration(
        color: appSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder(context)),
      ),
      child: TextFormField(
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        validator: validate,
        onTap: onTap,
        style: TextStyle(
          color: appTextPrimary(context),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: appTextMuted(context),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          prefixIcon:
              prefixIcon == null
                  ? null
                  : Icon(prefixIcon, color: appTextMuted(context), size: 20),
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
