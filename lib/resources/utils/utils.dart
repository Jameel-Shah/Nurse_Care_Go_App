import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class Utils {
  //Success toast message
  static void showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.greenColor,
      textColor: AppColors.whiteColor,
      fontSize: 16.0,
    );
  }

  //Error toast message
  static void showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.redColor,
      textColor: AppColors.whiteColor,
      fontSize: 16.0,
    );
  }

  //Error Dialog
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    // required Color color
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.blueColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Booking success Dialog
  static void showBookingSuccessDialog({
    required BuildContext context,
    required String message,
    required VoidCallback onOkPress
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Image(
          image: AssetImage('assets/images/successIcon.png'),
          height: 100.h,
          alignment: AlignmentGeometry.center,
          fit: BoxFit.contain,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                onOkPress();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.blueColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation dialog
  static void showConfirmationDialog({
    required BuildContext context,
    required VoidCallback onPress,
    required String title
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 22,
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onPress();
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: AppColors.greenColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'No',
                style: TextStyle(
                  color: AppColors.redColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
