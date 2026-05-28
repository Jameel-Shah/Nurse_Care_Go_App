import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../resources/colors/colors.dart';

class AcceptButton extends StatelessWidget {
  final VoidCallback onPress;
  final bool isUpdating;
  const AcceptButton({super.key, required this.onPress, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.blueColor
      ),
      onPressed: onPress, child:  isUpdating
        ? const SizedBox(
      height: 18,
      width: 18,
      child: SpinKitFadingCircle(color: AppColors.whiteColor),
    )
        : Text(
      'Accept',
      style: TextStyle(
        color: AppColors.whiteColor,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        fontFamily: 'Poppins',
      ),
    ),);
  }
}
