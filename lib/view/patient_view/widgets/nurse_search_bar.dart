import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class NurseSearchBar extends StatelessWidget {
  final SearchController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;
  const NurseSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SearchBar(
        controller: controller,
        hintText: 'Find a nurse...',
        hintStyle: WidgetStateProperty.all(Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor)),
        textStyle: WidgetStateProperty.all(Theme.of(context).textTheme.bodyMedium),
        leading: Icon(Icons.search, color: AppColors.greyColor,),
        onChanged: onChanged,
        trailing: [
          if (controller.text.isNotEmpty)
            IconButton(onPressed: onClear, icon: Icon(Icons.clear)),
        ],
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8.0.r, vertical: 8.0.r)),
        elevation: WidgetStatePropertyAll(1),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),side: BorderSide(color: AppColors.greyColor))),


      ),
    );
  }
}
