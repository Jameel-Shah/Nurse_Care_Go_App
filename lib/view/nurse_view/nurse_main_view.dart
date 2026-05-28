import 'package:flutter/material.dart';
import 'package:project_uaf/view/nurse_view/widgets/nurse_navigation_bar.dart';
class NurseMainView extends StatelessWidget {
  final String nurseId;
  const NurseMainView({super.key, required this.nurseId,});

  @override
  Widget build(BuildContext context) {
    return NurseNavigationBar(nurseId: nurseId,);
  }
}
