import 'package:flutter/material.dart';
import 'package:project_uaf/view/patient_view/widgets/patient_navigation_bar.dart';
class PatientMainView extends StatelessWidget {
  final String patientId;
  const PatientMainView({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return PatientNavigationBar(patientId: patientId,);
  }
}
