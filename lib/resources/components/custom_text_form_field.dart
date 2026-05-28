import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hint;
  final String? suffixText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization? textCapitalization;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final void Function(String)? onFieldSubmitted;
  const CustomTextFormField({
    super.key,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    required this.keyboardType,
    this.onFieldSubmitted,
    this.suffixIcon,  this.textCapitalization, this.focusNode, this.textInputAction,  this.suffixText, this.maxLines=1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      style:Theme.of(context).textTheme.bodyMedium,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        focusColor: AppColors.blueColor,
        suffixIcon: suffixIcon,
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(
          color: AppColors.greyColor
        )),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.blueColor, width: 1.0),
        ),
      ),
    );
  }
}
