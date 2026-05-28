import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/model/patient_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/button_widget.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/resources/components/logout_button.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/auth_services.dart';
import 'package:project_uaf/services/cache_service.dart';
import 'package:project_uaf/services/chat_service.dart';
import 'package:project_uaf/view/auth_view/login_view/login_view.dart';
import 'package:project_uaf/view/patient_view/patient_edit_profile_view.dart';

import '../../services/patient_service.dart';
class PatientProfileView extends StatefulWidget {
  final String patientId;
  const PatientProfileView({super.key, required this.patientId});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView> {
  // Instance to use chat service class
  final ChatService _chatService= ChatService();
  // Instance to use cache-service class
  final CacheService _cacheService= CacheService();
  // Instance to use auth-services class
  final AuthServices _authServices= AuthServices();
  // Method for logout
  Future<void> _logOut()async {
    try {
      await _chatService.setOffline(widget.patientId);
      await _authServices.logOutUser();
      await _cacheService.clearCache();
      Utils.showSuccessMessage('Logout Successfully');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => LoginView()), (
          route) => false);
    } on AppException catch (e) {
      if (!mounted) return;
      Utils.showErrorDialog(
          context: context, title: 'Error', message: e.message);
    }
  }
  // Instance to use patient service class
  final PatientService _patientService = PatientService();
  // Instance to use patient model
     late Future<PatientModel?> _profileFuture;
     void _reload(){
       setState(() {
         _profileFuture= _patientService.fetchPatient(widget.patientId);
       });
     }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profileFuture= _patientService.fetchPatient(widget.patientId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(22.r),
      child: FutureBuilder<PatientModel?>(future: _profileFuture, builder: (context, snapshot){
        if(snapshot.connectionState== ConnectionState.waiting){
          return SpinKitFadingCircle(color: AppColors.blueColor,);
        }
        if(snapshot.hasError || !snapshot.hasData){
          final message= snapshot.error is AppException?(snapshot.error as AppException).message: 'Something went wrong. Could not load data';
          return GeneralExceptionWidget(onPress: _reload, message: message);
        }
        final patient= snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h,),
              Center(
                child: CircleAvatar(
                  radius: 70.r,
                  backgroundImage: patient.profileImageUrl.isNotEmpty
                      ? NetworkImage(patient.profileImageUrl)
                      : null,
                  child: patient.profileImageUrl.isEmpty
                      ? Text( patient.firstName[0].toUpperCase(), style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 50.sp,
                    fontFamily: 'Poppins'
                  ),)
                      : null,
                ),
              ),
              SizedBox(height: 16.h,),
              Text('Full-Name', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(height: 8.h,),
              Text('${patient.firstName} ${patient.lastName}', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 12.h,),
              Text('Phone Number', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(height: 8.h,),
              Text(patient.phoneNumber, style: Theme.of(context).textTheme.bodyMedium,),
              SizedBox(height: 12.h,),
              Text('Email', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(height: 8.h,),
              Text(patient.email, style: Theme.of(context).textTheme.bodyMedium,),
              SizedBox(height: 12.h,),
              Text('City & Province/Region', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(height: 8.h,),
              Text('${patient.city},${patient.provinceRegion}', style: Theme.of(context).textTheme.bodyMedium,),
              SizedBox(height: 12.h,),
              Text('Address', style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(height: 8.h,),
              Text(patient.address, style: Theme.of(context).textTheme.bodyMedium,),
              SizedBox(height: 16.h,),
              ButtonWidget(title: 'Edit Profile', onTap: ()async{
                await Navigator.push(context,MaterialPageRoute(builder: (context)=> PatientEditProfileView(patient: patient)));
                setState(() {
                  _profileFuture= _patientService.fetchPatient(widget.patientId);
                });
              }),
              SizedBox(height: 12.h,),
              LogoutButton(onPress: (){
                Utils.showConfirmationDialog(context: context, onPress: _logOut
                    , title: 'Are you sure, you want to logout?');
              })
            ],
          ),
        );
      })),
    );
  }
}
