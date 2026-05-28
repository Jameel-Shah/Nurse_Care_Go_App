import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/model/nurse_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class NurseHeader extends StatelessWidget {
  final NurseModel nurse;
  const NurseHeader({super.key, required this.nurse});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome Back!', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),),
          SizedBox(height: 10.h,),
          Text('${nurse.firstName} ${nurse.lastName}', style: Theme.of(context).textTheme.titleMedium,),
          SizedBox(height: 5.h,),
          Text('${nurse.city},${nurse.provinceRegion}', style: Theme.of(context).textTheme.bodyMedium,)
        ]),
        _buildAvatar()
      ],

    );
  }

  Widget _buildAvatar() {
    // If image Url exists, show the image. Otherwise show first letter
    if (nurse.profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30.r,
        backgroundImage: NetworkImage(nurse.profileImageUrl),
      );
    }
    return CircleAvatar(
      radius: 30.r,
      child: Text(
        nurse.firstName.isNotEmpty ? nurse.firstName[0].toUpperCase() : '?',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25.sp),
      ),
    );
  }
}
