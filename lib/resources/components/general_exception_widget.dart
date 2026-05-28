import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class GeneralExceptionWidget extends StatefulWidget {
  final VoidCallback onPress;
  final String message;
  const GeneralExceptionWidget({super.key, required this.onPress, required this.message});

  @override
  State<GeneralExceptionWidget> createState() => _GeneralExceptionWidgetState();
}

class _GeneralExceptionWidgetState extends State<GeneralExceptionWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.redColor, size: 70.r,),
            Center(child: Text(widget.message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.greyColor),),),
            SizedBox(height: 16.h,),
            Padding(padding: EdgeInsets.only(top: 20.r),
              child: ElevatedButton(onPressed: widget.onPress, style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor
              ), child: Text('Retry', style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  fontFamily: 'Poppins'
              ),)),)

          ],
        ),),
    );
  }
}
