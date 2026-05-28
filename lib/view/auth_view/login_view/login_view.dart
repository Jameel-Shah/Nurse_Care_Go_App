import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/components/button_widget.dart';
import 'package:project_uaf/resources/components/custom_text_form_field.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/auth_services.dart';
import 'package:project_uaf/view/auth_view/signUp_view/sign_up_view.dart';
import 'package:project_uaf/view/auth_view/widgets/text_input_button.dart';
import 'package:project_uaf/view/nurse_view/nurse_main_view.dart';
import 'package:project_uaf/view/patient_view/patient_main_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthServices _authServices= AuthServices();
  // It is a variable for 'Don't navigate twice'.
  bool _isNavigation = false;
  bool _passwordHidden = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(22.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 250.h,
                      child: Image(
                        image: AssetImage(
                          'assets/images/Nurse_Care_Go_logo.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Welcome Back! Enter Your Account Details',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextFormField(
                    focusNode: _emailFocusNode,
                    textInputAction: TextInputAction.next,
                    hint: 'Email Address...',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    // Moves to password field
                    onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email address is required';
                      }
                      if (!EmailValidator.validate(value.trim())) {
                        return 'Please Enter a valid Email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    focusNode: _passwordFocusNode,
                    textInputAction: TextInputAction.done,
                    hint: 'Password...',
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _passwordHidden,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordHidden = !_passwordHidden;
                        });
                      },
                      icon: Icon(
                        _passwordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    // Now, we trigger form submission
                    onFieldSubmitted: (_)=> _login(),
                    validator: (value) {
                      final trimmedValue = value?.trim() ?? "";
                      if (trimmedValue.isEmpty) return "Password is required";
                      if (trimmedValue.length < 8 || trimmedValue.length > 12) {
                        return "Password must be 8-12 characters";
                      }
                      final passwordRegex = RegExp(
                        r'[0-9!@#\$%^&*(),.?":{}|<>]',
                      );
                      if (!passwordRegex.hasMatch(trimmedValue)) return "Use at least one number or special character";
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  ButtonWidget(
                    title: 'Sign In',
                    isLoading: _isLoading,
                    onTap: _login,
                  ),
                  SizedBox(height: 36.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextInputButton(
                        title: 'SignUp',
                        onPress: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpView()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Login method
Future<void> _login() async{
    if(_formKey.currentState!.validate()){
      setState(() {
        _isLoading=true;
      });
      try{
        final role = await _authServices.loginUser(email: _emailController.text.trim(), password: _passwordController.text.trim());
        Utils.showSuccessMessage('Logged-in successfully');
        if(!mounted) return;
        switch(role){
          case UserRole.patient:
            _navigateToPatient();
          case UserRole.nurse:
            _navigateToNurse();
          case UserRole.unknown:
            Utils.showErrorDialog(context: context,title: 'Error', message: 'Account type not found. Please register.');
        }
      } on AppException catch(e){
        if(!mounted) return;
        Utils.showErrorDialog(context: context, title: 'Error', message: e.message);
      } finally{
        if(mounted) {
          setState(() {
          _isLoading= false;
        });
        }

      }
    }
}
  // Method for navigating to nurse home screen
  void _navigateToNurse() {
    // Only navigate if we haven't navigate already
    if (!_isNavigation) {
      // Once the navigation starts block future navigation
      _isNavigation = true;
      // Firebase Auth already holds the logged-in user id after loginUser() succeeds
      // current user is not always null because the login just succeeded
      final String uid= FirebaseAuth.instance.currentUser!.uid;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => NurseMainView(nurseId: uid,)),
            (Route<dynamic> route) => false,
      );
    }
  }

  // Method for navigating to patient home screen
  void _navigateToPatient() {
    // Only navigate if we haven't navigate already
    if (!_isNavigation) {
      // Once the navigation starts block future navigation
      _isNavigation = true;
      // Firebase Auth already holds the logged-in user id after loginUser() succeeds
      // current user is not always null because the login just succeeded
      final String uid= FirebaseAuth.instance.currentUser!.uid;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PatientMainView(patientId: uid,)),
            (Route<dynamic> route) => false,
      );
    }
  }
}
