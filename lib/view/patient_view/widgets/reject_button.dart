import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../resources/colors/colors.dart';

class RejectButton extends StatelessWidget {
  final VoidCallback onPress;
  final bool isUpdating;
  const RejectButton({
    super.key,
    required this.onPress,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        side: const BorderSide(color: AppColors.redColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ),
      onPressed: onPress,
      child: isUpdating
          ? const SizedBox(
              height: 18,
              width: 18,
              child: SpinKitFadingCircle(color: AppColors.redColor),
            )
          : Text(
              'Reject',
              style: TextStyle(
                color: AppColors.redColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
              ),
            ),
    );
  }
}
