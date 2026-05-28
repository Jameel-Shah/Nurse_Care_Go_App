import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/colors/colors.dart';
class ImageBottomSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  const ImageBottomSheet({super.key, required this.onCameraTap, required this.onGalleryTap});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(12.0),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 30,
      runSpacing: 30,
      children: [
        _optionItem(icon: Icons.camera_alt, label: "Camera", onTap: onCameraTap),
        _optionItem(icon: Icons.browse_gallery, label: "Gallery", onTap: onGalleryTap)

      ],
    ),);
  }
  Widget _optionItem({
  required IconData icon,
    required String label,
    required VoidCallback onTap,
}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(64, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(5),
          color: Colors.white60
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.blueColor,),
            Text(label, style: TextStyle(color: AppColors.blueColor, fontFamily: "Poppins", fontWeight: FontWeight.w400, fontSize: 14.sp),)
          ],
        ),
      ),
    );
  }
}
