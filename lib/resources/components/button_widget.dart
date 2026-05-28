import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  const ButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.blueColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: isLoading? Center(child: SpinKitFadingCircle(
          color: AppColors.whiteColor,
        ),) : Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.whiteColor,
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
