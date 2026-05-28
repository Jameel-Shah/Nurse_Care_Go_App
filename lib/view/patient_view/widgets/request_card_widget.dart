import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/model/booking_model.dart';
import 'package:project_uaf/model/patient_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/status_badge.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/services/patient_service.dart';

class RequestCardWidget extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  const RequestCardWidget({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  State<RequestCardWidget> createState() => _RequestCardWidgetState();
}

class _RequestCardWidgetState extends State<RequestCardWidget> {
  // Instance to use patient service class
  final PatientService _patientService = PatientService();
  // loading indicator for loading patient data on card
  bool _isLoading = true;
  // Error indicator
  bool _hasError= true;
  // Nullable instance to use patient model
  PatientModel? _patient;
  // Method for fetching patient data
  Future<void> _loadPatient() async {
    setState(() {
      _isLoading=true;
      _hasError=false;
    });
    try {
      final patient = await _patientService.fetchPatient(
        widget.booking.patientId,
      );
      if (mounted) {
        setState(() {
          _patient = patient;
          _isLoading = false;
        });
      }
    } on AppException catch (_) {
      // If patient data fetch fails just show booking info only
      // Card should not crash the whole home screen
      if (mounted){
        setState(() {
          _isLoading = false;
          _hasError=true;
        } );
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPatient();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hasError? null :widget.onTap, // tapping will be disabled when error will occur
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(padding: EdgeInsets.all(16.r),
        child: _isLoading?
        _buildSkeleton() :
        _hasError?
        _buildErrorRow(): // This will prevent crash and null error
        _buildContent(),),
      ),
    );
  }

  Widget _buildErrorRow(){
    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: AppColors.greyColorShade100,
          child: Icon(Icons.person_off_outlined, size: 20.sp,color: AppColors.greyColor,),
        ),
        SizedBox(width: 12.w,),
        Expanded(child: Text('Could not load patient info.', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),)),
        TextButton(onPressed: _loadPatient, child: Text('Retry', style: TextStyle(color: AppColors.blueColor, fontFamily: 'Poppins', fontSize: 12.sp),))
      ],
    );
  }
  // Now we build a placeholder/skeleton widget which will be shown while patient data is loading
  // Simple placeholder so layout does not jump
  Widget _buildSkeleton() {
    return Row(
      children: [
        // Avatar place holder
        CircleAvatar(
          radius: 24.r,
          backgroundColor: AppColors.greyColorShade100,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name placeholder
              Container(
                height: 14.h,
                width: 120.w,
                decoration: BoxDecoration(
                  color: AppColors.greyColorShade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 6.h),
              // City placeholder
              Container(
                height: 12.h,
                width: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.greyColorShade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Now we build actual content widget
Widget _buildContent(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      // Patient Avatar
        _buildAvatar(),
        SizedBox(width: 12.w,),
        // Patient info + booking summary
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_patient!=null? '${_patient!.firstName} ${_patient!.lastName}': 'Unknown Patient', style: Theme.of(context).textTheme.titleMedium,),
                StatusBadge(status: widget.booking.status),
              ],
            ),
            SizedBox(height: 2.h,),
            // City & Province
            if(_patient!=null)
              Text('${_patient!.city}, ${_patient!.provinceRegion}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),),
            SizedBox(height: 6.h,),
            // Booking summary --- hours & fee only
            Row(
              children: [
                Icon(Icons.timeline_outlined, size: 14.sp,color: AppColors.greyColor,),
                SizedBox(width: 4.w,),
                Text('${widget.booking.hours} hrs', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),),
                SizedBox(width: 12.w,),
                Icon(Icons.attach_money, size: 14.sp,color: AppColors.greyColor,),
                SizedBox(width: 4.w,),
                Text('PKR. ${widget.booking.totalFee.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),)
              ],
            )
          ],
        )),
        // Right---Chevron to indicate card is tappable
        Icon(Icons.chevron_right, color: AppColors.greyColor, size: 20.sp,)
      ],
    );
}

// Widget for displaying image in circle avatar or name's text
  Widget _buildAvatar() {
    // Creating an instance of patientModel so we can use PatientModel which should not be null
    final patient = _patient!;
    // If image Url exists, show the image. Otherwise show first letter
    return CircleAvatar(
      radius: 24.r,
      backgroundImage: patient.profileImageUrl.isNotEmpty
          ? NetworkImage(patient.profileImageUrl)
          : null,
      child: patient.profileImageUrl.isEmpty
          ? Text(
        patient.firstName[0].toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          fontFamily: 'Poppins',
        ),
      )
          : null,
    );
  }
}
