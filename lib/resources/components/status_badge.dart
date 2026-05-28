import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../colors/colors.dart';
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
     // Each status will have its own color
    final Map<String, Color> backgroundColors = {
      'pending': AppColors.orangeColorShade50,
      'accepted': AppColors.greenColorShade50,
      'rejected': AppColors.redColorShade50,
      'cancelled': AppColors.greyColorShade100,
    };
    final Map<String, Color> textColors = {
      'pending': AppColors.orangeColor,
      'accepted': AppColors.greenColor,
      'rejected': AppColors.redColor,
      'cancelled': AppColors.greyColor,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColors[status] ?? AppColors.greyColorShade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: textColors[status] ?? AppColors.greyColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
