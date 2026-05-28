import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colors/colors.dart';

class GenderRadioGroup extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onChanged;
  const GenderRadioGroup({
    super.key,
    this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8.h),
        RadioGroup<String>(
          onChanged: onChanged,
          groupValue: selectedGender,
          child: Row(
            children:  [
              Expanded(
                child: RadioListTile<String>(
                  activeColor: AppColors.blueColor,
                  value: "Male",
                  title: Text("Male", style: Theme.of(context).textTheme.bodyMedium,),
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  activeColor: AppColors.blueColor,
                  value: "Female",
                  title: Text("Female", style:Theme.of(context).textTheme.bodyMedium),
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
