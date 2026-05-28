import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/model/nurse_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/button_widget.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/resources/components/logout_button.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/auth_services.dart';
import 'package:project_uaf/services/nurse_service.dart';
import 'package:project_uaf/view/auth_view/login_view/login_view.dart';
import 'package:project_uaf/view/nurse_view/nurse_edit_profile_view.dart';
import '../../services/cache_service.dart';
import '../../services/chat_service.dart';


class NurseProfileView extends StatefulWidget {
  final String nurseId;
  const NurseProfileView({super.key, required this.nurseId});

  @override
  State<NurseProfileView> createState() => _NurseProfileViewState();
}

class _NurseProfileViewState extends State<NurseProfileView> {
  // Instance to use chat service class
  final ChatService _chatService= ChatService();
  // Instance to use cache-service class
  final CacheService _cacheService= CacheService();
  // Instance to use auth-services class
  final AuthServices _authServices= AuthServices();
  // Method for logout
  Future<void> _logOut()async {
    try {
      await _chatService.setOffline(widget.nurseId);
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
  final NurseService _nurseService= NurseService();
  // Instance to use patient model
  late Future<NurseModel?> _nurseProfileFuture;
  void _reload(){
    setState(() {
      _nurseProfileFuture= _nurseService.fetchNurseById(widget.nurseId);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nurseProfileFuture= _nurseService.fetchNurseById(widget.nurseId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(22.r),
          child: FutureBuilder<NurseModel?>(future: _nurseProfileFuture, builder: (context, snapshot){
            if(snapshot.connectionState== ConnectionState.waiting){
              return SpinKitFadingCircle(color: AppColors.blueColor,);
            }
            if(snapshot.hasError || !snapshot.hasData){
              final message= snapshot.error is AppException?(snapshot.error as AppException).message: 'Something went wrong. Could not load data';
              return GeneralExceptionWidget(onPress: _reload, message: message);
            }
            final nurse= snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h,),
                  Center(
                    child: CircleAvatar(
                      radius: 70.r,
                      backgroundImage: nurse.profileImageUrl.isNotEmpty
                          ? NetworkImage(nurse.profileImageUrl)
                          : null,
                      child: nurse.profileImageUrl.isEmpty
                          ? Text( nurse.firstName[0].toUpperCase(), style: TextStyle(
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
                  Text('${nurse.firstName} ${nurse.lastName}', style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 12.h,),
                  Text('Phone Number', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.phoneNumber, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Email', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.email, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('City & Province/Region', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text('${nurse.city},${nurse.provinceRegion}', style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Address', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.address, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Gender', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.gender, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Qualification', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.qualification, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Specialization in', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.categorySpecialization, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Years of Experience', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.yearsOfExperience, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Availability', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.availability, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Work-Place', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text(nurse.workPlace, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 12.h,),
                  Text('Service/Hourly Fee', style: Theme.of(context).textTheme.titleMedium,),
                  SizedBox(height: 8.h,),
                  Text('PKR ${nurse.serviceFee}/hr', style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 16.h,),
                  ButtonWidget(title: 'Edit Profile', onTap: ()async{
                    await Navigator.push(context, MaterialPageRoute(builder: (context)=> NurseEditProfileView(nurse: nurse)));
                    setState(() {
                      _nurseProfileFuture= _nurseService.fetchNurseById(widget.nurseId);
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
