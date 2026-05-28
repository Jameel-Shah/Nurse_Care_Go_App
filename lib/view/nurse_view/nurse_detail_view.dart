import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/resources/components/button_widget.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/view/chat_view/chat_view.dart';
import 'package:project_uaf/view/nurse_view/widgets/action_button.dart';
import 'package:project_uaf/view/patient_view/confirm_booking_view.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';
import '../../model/nurse_model.dart';
import '../../resources/colors/colors.dart';

class NurseDetailView extends StatefulWidget {
  final NurseModel nurse;
  const NurseDetailView({super.key, required this.nurse});

  @override
  State<NurseDetailView> createState() => _NurseDetailViewState();
}

class _NurseDetailViewState extends State<NurseDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppbar(),
      body: Padding(padding: EdgeInsets.all(22.r),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  _buildAvatar(),
                  SizedBox(height: 12.h,),
                  Text('${widget.nurse.firstName} ${widget.nurse.lastName}',textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium,),
                  SizedBox(height: 6.h,),
                  Text(widget.nurse.categorySpecialization, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),),
                ],
              ),
            ),
            SizedBox(height: 6.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                  _customColumn(label: widget.nurse.yearsOfExperience, numValue: 'Years of experience'),
                  _customColumn(label: widget.nurse.averageRating.toString(), numValue: 'Rating'),
                _customColumn(label: widget.nurse.totalReviews.toString(), numValue: 'Reviews')
              ],
            ),
            SizedBox(height: 16.h,),
            Text('From', style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text('${widget.nurse.city}, ${widget.nurse.provinceRegion}', style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 12.h,),
            Text('Gender', style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text(widget.nurse.gender, style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 12.h,),
            Text('Qualification', style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text(widget.nurse.qualification, style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 12.h,),
            Text('Availability', style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text(widget.nurse.availability, style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 12.h,),
            Text('Work-Place', style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text(widget.nurse.workPlace, style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 12.h,),
            Text('Email', style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text(widget.nurse.email, style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 12.h,),
            Text('Phone No', style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text(widget.nurse.phoneNumber, style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 12.h,),
            Text('Service/Hourly Fee',style: Theme.of(context).textTheme.titleMedium,),
            SizedBox(height: 8.h,),
            Text('Rs. ${widget.nurse.serviceFee}/hr', style: Theme.of(context).textTheme.bodyMedium,),
            SizedBox(height: 16.h,),
            ButtonWidget(title: 'Book Now', onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ConfirmBookingView(nurse: widget.nurse)));
            })
          ],
        ),
      ),),
    );
  }

  AppBar _buildAppbar(){
    return AppBar(
      backgroundColor: AppColors.transparent,
      title: Text('Nurse Details', style: Theme.of(context).textTheme.titleMedium,),
      actions: [
        ActionButton(icon: Icons.phone, onPress: ()=> _makePhoneCall(widget.nurse.phoneNumber)),
        ActionButton(icon: Icons.chat, onPress: (){
          // Adding chat functionality
           String currentUserId= FirebaseAuth.instance.currentUser!.uid;
          String nurseName= '${widget.nurse.firstName} ${widget.nurse.lastName}';
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatView(
            nurseId: widget.nurse.uid,
            nurseName: nurseName,
            nurseProfilePic: widget.nurse.profileImageUrl,
            patientId: currentUserId,
          )));
        }),
        ActionButton(icon: Icons.map_outlined, onPress: ()=> _openGoogleMaps())
      ],
    );
  }

  // Widget for displaying image in circle avatar or name's text
  Widget _buildAvatar() {
    // If image Url exists, show the image. Otherwise show first letter
    if (widget.nurse.profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 70.r,
        backgroundImage: NetworkImage(widget.nurse.profileImageUrl),
      );
    }
    return CircleAvatar(
      radius: 70.r,
      child: Text(
        widget.nurse.firstName.isNotEmpty ? widget.nurse.firstName[0].toUpperCase() : '?',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 50.sp),
      ),
    );
  }

  // Custom column widget for displaying experience, reviews and ratings
  Widget _customColumn({
    required String label,
    required String numValue
}){
    return Column(
      children: [
        Text(numValue, style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.blue, fontFamily: 'Poppins'
        ),),
        SizedBox(height: 3.h,),
        Text(label, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12.sp, fontFamily: 'Poppins'),)
      ],
    );
  }

  // Method for making a call to nurse
  void _makePhoneCall(String phoneNumber)async{
    final Uri phoneUri= Uri(scheme: 'tel', path: phoneNumber);
    if(await url_launcher.canLaunchUrl(phoneUri)){
      await url_launcher.launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    }else{
      Utils.showErrorMessage('Could not make a call on $phoneNumber this number');
    }
  }

  // Method for opening Google maps
    void _openGoogleMaps()async{
    final Uri googleMapsUri= Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.nurse.latitude},${widget.nurse.longitude}');
    if(await url_launcher.canLaunchUrl(googleMapsUri)){
      await url_launcher.launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
    Utils.showErrorMessage('Could not open the map');
    }
}
