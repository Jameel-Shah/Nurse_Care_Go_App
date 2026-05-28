import 'package:flutter/material.dart';
import 'package:project_uaf/resources/colors/colors.dart';
class PickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPress;
  const PickerButton({super.key, required this.label, required this.icon, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueColor,
        foregroundColor: AppColors.whiteColor
      ),
      onPressed: onPress, label: Text(label, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.whiteColor),),
    icon: Icon(icon, size: 16,),);
  }
}
