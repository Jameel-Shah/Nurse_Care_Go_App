import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPress;
  const ActionButton({super.key, required this.icon, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPress, icon: Icon(icon, color: Colors.blue, size: 30.r,));
  }
}
