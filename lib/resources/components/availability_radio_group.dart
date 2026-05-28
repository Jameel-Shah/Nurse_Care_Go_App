import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class AvailabilityRadioGroup extends StatelessWidget {
  final String? selectedAvailability;
  final Function(String?) onChanged;
  const AvailabilityRadioGroup({
    super.key,
    this.selectedAvailability,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Availability", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8.h),
        RadioGroup<String>(
          onChanged: onChanged,
          groupValue: selectedAvailability,
          child: Row(
            children:  [
              Expanded(
                child: RadioListTile<String>(
                  activeColor: AppColors.blueColor,
                  value: "Full-Time",
                  title: Text("Full-Time", style: Theme.of(context).textTheme.bodyMedium,),
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  activeColor: AppColors.blueColor,
                  value: "Part-Time",
                  title: Text("Part-Time", style:Theme.of(context).textTheme.bodyMedium),
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
