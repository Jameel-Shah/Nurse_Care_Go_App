import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/model/nurse_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
class NurseCard extends StatelessWidget {
  final NurseModel nurse;
  const NurseCard({super.key, required this.nurse});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable= nurse.availability == 'Full-Time';
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          _buildAvatar(),
          SizedBox(width: 12.w,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${nurse.firstName} ${nurse.lastName}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor, fontWeight: FontWeight.w600 ),),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.amberColor, size: 16.r,),
                        Text('${nurse.averageRating}', style: Theme.of(context).textTheme.bodyMedium )
                      ],
                    )
                  ],
                ),
                Text('${nurse.categorySpecialization} ${nurse.yearsOfExperience} yrs experience', style: TextStyle(
                  fontSize: 12.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w400,
                ),),
                SizedBox(height: 5.h,),
                Text('${nurse.city}, ${nurse.provinceRegion}', style: TextStyle(
                  fontSize: 12.sp, fontWeight: FontWeight.w400, fontFamily: 'Poppins'
                ),),
                SizedBox(height: 5.h,),
                //Availability badge
                Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    color: isAvailable? Colors.green.shade100: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10.0.r)
                  ),
                  child: Text(isAvailable? 'Full-Time': 'Part-Time', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11.sp, fontWeight: FontWeight.w500, color: isAvailable? AppColors.greenColor: AppColors.orangeColor
                  ),),
                )
              ],
            ),
          )
        ],
      ),),
    );
  }

  Widget _buildAvatar() {
    // If image Url exists, show the image. Otherwise show first letter
    if (nurse.profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 35.r,
        backgroundImage: NetworkImage(nurse.profileImageUrl),
      );
    }
    return CircleAvatar(
      radius: 35.r,
      child: Text(
        nurse.firstName.isNotEmpty ? nurse.firstName[0].toUpperCase() : '?',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25.sp),
      ),
    );
  }
}
