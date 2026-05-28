import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/model/patient_model.dart';

import '../../../resources/colors/colors.dart';

class PatientHeader extends StatelessWidget {
  final PatientModel patient;
  const PatientHeader({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome Back!', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),),
          SizedBox(height: 10.h,),
          Text('${patient.firstName} ${patient.lastName}', style: Theme.of(context).textTheme.titleMedium,),
          SizedBox(height: 5.h,),
          Text('${patient.city},${patient.provinceRegion}', style: Theme.of(context).textTheme.bodyMedium,)
        ]),
        _buildAvatar()
      ],

    );
  }

  Widget _buildAvatar() {
    // If image Url exists, show the image. Otherwise show first letter
    if (patient.profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30.r,
        backgroundImage: NetworkImage(patient.profileImageUrl),
      );
    }
    return CircleAvatar(
      radius: 30.r,
      child: Text(
        patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : '?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
      ),
    );
  }
}
