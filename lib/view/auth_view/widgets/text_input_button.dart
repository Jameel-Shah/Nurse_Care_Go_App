import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resources/colors/colors.dart';

class TextInputButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  const TextInputButton({
    super.key,
    required this.title,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPress,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: AppColors.blueColor,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.blueColor,
        ),
      ),
    );
  }
}
