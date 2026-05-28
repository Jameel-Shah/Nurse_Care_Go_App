import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPress;
  const LogoutButton({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: onPress,
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            color: AppColors.redColor
          ),
        ),
        icon: Icon(Icons.logout, color: AppColors.redColor,),
        iconAlignment: IconAlignment.start,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: AppColors.redColor)
        ),
      ),
    );
  }
}
