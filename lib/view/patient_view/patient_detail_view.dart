import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/model/booking_model.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/services/nurse_booking_service.dart';
import 'package:project_uaf/services/patient_service.dart';
import 'package:project_uaf/view/patient_view/widgets/accept_button.dart';
import 'package:project_uaf/view/patient_view/widgets/reject_button.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';
import '../../model/patient_model.dart';
import '../../resources/colors/colors.dart';
import '../../resources/utils/error_handler.dart';
import '../../resources/utils/states.dart';
import '../../resources/utils/utils.dart';
import '../chat_view/chat_view.dart';
import '../nurse_view/widgets/action_button.dart';

class PatientDetailView extends StatefulWidget {
  final BookingModel booking;
  const PatientDetailView({super.key, required this.booking});

  @override
  State<PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<PatientDetailView> {
  // Instances to use patient and booking classes
  final PatientService _patientService = PatientService();
  final NurseBookingService _nurseBookingService = NurseBookingService();
  // Loading indicator for whole screen
  PageState _pageState = PageState.loading;
  // Variable for error message
  String _errorMessage = '';
  // --- Now we create a variable of the type 'PatientModel'
  // because it will help us fetch data of the patient through 'PatientModel'
  PatientModel? _patient;
  // Now we create a loading indicator variable that will help track loading of accept/reject status
  bool _isUpdating = false;
  // Method for loading patient's data
  Future<void> _loadPatientData() async {
    // Reset state to loading when retrying
    setState(() {
      _pageState = PageState.loading;
    });
    // print('_loadData started');
    try {
      final patient = await _patientService.fetchPatient(
        widget.booking.patientId,
      );
      // After successfully fetching patient data
      setState(() {
        _patient = patient;
        _pageState = PageState.success;
      });
      // print('pageState is now: $_pageState');
    } on AppException catch (e) {
      // print('AppException: ${e.message}');
      setState(() {
        _errorMessage = e.message;
        _pageState = PageState.error;
      });
    } catch (e) {
      // print('Unknown error: $e');
      setState(() {
        _errorMessage = e.toString();
        _pageState = PageState.error;
      });
    }
  }

  // Method for 'Accept and Reject' status
  Future<void> _updateStatus(String status) async {
    // 1. Show loading when updating status
    setState(() {
      _isUpdating = true;
    });
    try {
      await _nurseBookingService.updateBookingStatus(
        bookingId: widget.booking.bookingId,
        status: status,
      );
      // 2. After updating status(Accepted or Rejected), show success message
      if (!mounted) return;
      Utils.showSuccessMessage(
        status == 'accepted' ? 'Request accepted.' : 'Request rejected.',
      );
      // 3. Also navigate back to nurse home view where StreamBuilder will update status automatically
      Navigator.pop(context);
    } on AppException catch (e) {
      // 4. Clean app-level or Firebase errors
      if (mounted) {
        Utils.showErrorDialog(
          context: context,
          title: 'Error',
          message: e.message,
        );
      }
    } finally {
      // 5. Always runs and stops loading animation whether the operation succeeds or fails
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPatientData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppbar(),
      body: switch(_pageState){
        PageState.loading=>  Center(
          child: SpinKitFadingCircle(color: AppColors.blueColor,),
        ),
      PageState.error=> GeneralExceptionWidget(onPress: _loadPatientData, message: _errorMessage),
      PageState.success=> _buildBody()
      },
    );
  }

  // The whole UI
  Widget _buildBody() {
    // Creating an instance of patientModel so we can use PatientModel which should not be null
    final patient = _patient!;
    // Also creating an instance of bookingModel so we can use bookingModel
    final booking = widget.booking;
    return SingleChildScrollView(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                _buildAvatar(),
                SizedBox(height: 8.h),
                Text(
                  '${patient.firstName} ${patient.lastName}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // --- Patient-info section ---
          Center(
            child: Text(
              'Patient Information',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: 12.h),
          Text('From', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text(
            '${patient.city}, ${patient.provinceRegion}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 12.h),
          Text('Email', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text(patient.email, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 12.h),
          Text('Phone No', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text(
            patient.phoneNumber,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          // --- Booking Info Section ---
          SizedBox(height: 24.h),
          Center(
            child: Text(
              'Booking Details',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Booking Date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          Text(booking.date, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 12.h),
          Text(
            'Booking time',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          Text(booking.time, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 12.h),
          Text('Booking Fee', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text(
            'PKR. ${booking.totalFee.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 12.h),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text(
            booking.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24.h),
          // Accept/Reject Buttons
          // We will show these buttons if the booking is still pending
          if(booking.status== 'pending') _buildActionButtons(),
          // If booking is already accepted or rejected then
          if(booking.status != 'pending')
            Center(
              child: Text('This request has been ${booking.status}.',style: Theme.of(context).textTheme.bodyMedium,),
            )
        ],
      ),
    );
  }

  // AppBar
  AppBar _buildAppbar() {
    // Also creating an instance of bookingModel so we can use bookingModel
    final booking = widget.booking;
    return AppBar(
      backgroundColor: AppColors.transparent,
      title: Text(
        'Patient Details',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: _patient== null ?[]:[
        ActionButton(
          icon: Icons.phone,
          onPress: () => _makePhoneCall(_patient!.phoneNumber),
        ),
        ActionButton(
          icon: Icons.chat,
          onPress: () {
            // Adding chat functionality
            String currentUserId = FirebaseAuth.instance.currentUser!.uid;
            String patientName = '${_patient!.firstName} ${_patient!.lastName}';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatView(
                  nurseId: currentUserId,
                  patientProfilePic: _patient!.profileImageUrl,
                  patientName: patientName,
                  patientId: booking.patientId,
                ),
              ),
            );
          },
        ),
         ActionButton(icon: Icons.map_outlined, onPress: ()=> _openGoogleMaps())
      ],
    );
  }

  // Widget for displaying image in circle avatar or name's text
  Widget _buildAvatar() {
    // Creating an instance of patientModel so we can use PatientModel which should not be null
    final patient = _patient!;
    // If image Url exists, show the image. Otherwise show first letter
    return CircleAvatar(
      radius: 70.r,
      backgroundImage: patient.profileImageUrl.isNotEmpty
          ? NetworkImage(patient.profileImageUrl)
          : null,
      child: patient.profileImageUrl.isEmpty
          ? Text(
              patient.firstName[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 50.sp,
                fontFamily: 'Poppins',
              ),
            )
          : null,
    );
  }

  // Accept/Reject buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        // First we call reject button
        Expanded(
          child: RejectButton(
            onPress: () {
              Utils.showConfirmationDialog(
                context: context,
                onPress: () => _updateStatus('rejected'),
                title: 'Are you sure you want to reject this request?',
              );
            },
            isUpdating: _isUpdating,
          ),
        ),
        SizedBox(width: 12.w,),
        // Accept Button
        Expanded(child: AcceptButton(onPress: (){
          Utils.showConfirmationDialog(context: context, onPress: ()=> _updateStatus('accepted'), title: 'Are you sure you want to accept this request?');
        }, isUpdating: _isUpdating))
      ],
    );
  }

  // Method for making a call to nurse
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await url_launcher.canLaunchUrl(phoneUri)) {
      await url_launcher.launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Utils.showErrorMessage(
        'Could not make a call on $phoneNumber this number',
      );
    }
  }
  // Method for opening Google maps
  void _openGoogleMaps()async{
    final Uri googleMapsUri= Uri.parse('https://www.google.com/maps/search/?api=1&query=${_patient!.latitude},${_patient!.longitude}');
    if(await url_launcher.canLaunchUrl(googleMapsUri)){
      await url_launcher.launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
    Utils.showErrorMessage('Could not open the map');
  }
}
