import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/colors/colors.dart';
class DetailRowWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;
  const DetailRowWidget({super.key, required this.icon, required this.text, this.maxLines=2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.greyColor,),
          SizedBox(width: 6.w,),
          Expanded(child: Text(maxLines: maxLines,
            text, softWrap: true, overflow: TextOverflow.visible,
             style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),))
        ],
      ),
    );
  }
}
