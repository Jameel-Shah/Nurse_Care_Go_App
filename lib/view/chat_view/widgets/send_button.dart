import 'package:flutter/material.dart';
import 'package:project_uaf/resources/colors/colors.dart';
class SendButton extends StatelessWidget {
  final VoidCallback onPress;
  const SendButton({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPress, icon: Icon(Icons.send, size: 28, color: AppColors.blueColor,));
  }
}
