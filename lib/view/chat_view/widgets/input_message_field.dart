import 'package:flutter/material.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class InputMessageField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged onSubmitted;
  const InputMessageField({super.key, required this.controller, required this.keyboardType,required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: null,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        filled: true,
        fillColor:  AppColors.newColor4,
        hintText: 'Enter your message...',
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.greyColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.blueColor)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBlueColor, width: 1.5),
          borderRadius: BorderRadius.circular(8)
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
