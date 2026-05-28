import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/services/auth_services.dart';
import 'package:project_uaf/view/auth_view/login_view/login_view.dart';
import 'package:project_uaf/view/nurse_view/nurse_main_view.dart';
import 'package:project_uaf/view/patient_view/patient_main_view.dart';
import '../../services/splash_services.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  // Creating an object/instance of 'SplashServices' class to access properties of 'SplashServices'
  final SplashServices _splashServices = SplashServices();
  bool _showRetry = false;
  String _errorMessage = '';

  // Method for checking logged-in user whether they are Nurse or Patient and navigate to their screens based on role
  Future<void> _checkAuth() async {
    // Refresh the app
    setState(() {
      _showRetry = false;
      _errorMessage = '';
    });
    // Using try-catch to clearly catch errors in-case operation fails
    try {
      final results= await Future.wait([_splashServices.checkAuthStatus(), Future.delayed(const Duration(seconds: 2))]);
      // Get user-type by calling 'checkAuthStatus' from 'SplashServices' class
      final role = await results[0] as UserRole;
      // using 'mounted' in across async gaps
      if (!mounted) return;
      // Now using switch statement decide where to navigate based on returned 'UserRole'
      switch (role) {
        case UserRole.nurse:
          // Getting current user id if checkAuthStatus method succeeds
          final String uid = FirebaseAuth.instance.currentUser!.uid;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NurseMainView(nurseId: uid),
            ),
          );
        case UserRole.patient:
          // Getting current user id if checkAuthStatus method succeeds
          final String uid = FirebaseAuth.instance.currentUser!.uid;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PatientMainView(patientId: uid),
            ),
          );
        case UserRole.unknown:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginView()),
          );
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _showRetry = true;
        _errorMessage = e.message;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Center(
          child: _showRetry
              ? GeneralExceptionWidget(
                  onPress: _checkAuth,
                  message: _errorMessage,
                )
              : Column(
                  children: [
                    Spacer(),
                    SizedBox(
                      height: 300.h,
                      child: Image.asset(
                        'assets/images/Nurse_Care_Go_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}
