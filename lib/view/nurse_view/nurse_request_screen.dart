import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/model/booking_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/services/nurse_booking_service.dart';
import 'package:project_uaf/view/patient_view/patient_detail_view.dart';
import 'package:project_uaf/view/patient_view/widgets/request_card_widget.dart';

class NurseRequestScreen extends StatefulWidget {
  final String nurseId;
  const NurseRequestScreen({super.key, required this.nurseId});

  @override
  State<NurseRequestScreen> createState() => _NurseRequestScreenState();
}

class _NurseRequestScreenState extends State<NurseRequestScreen> {
  // Instance to use nurse-service class
  final NurseBookingService _service = NurseBookingService();
  Timer? _timedOutTimer; // This will help track the timeout
  bool _timedOut = false; // controls which widget to show
  // Now we add a unique key that will force 'streamBuilder' to restart
  // When key changes, streamBuilder disposes old stream and creates a new one
  Key _streamKey = UniqueKey();
  void _startTimeOutTimer() {
    // cancel any existing timer before staring a new one,
    // also this helps prevents multiple timers running in the background
    _timedOutTimer?.cancel();
    _timedOutTimer = Timer(const Duration(seconds: 8), () {
      // Only executes or fires if stream has not delivered anything yet
      if (mounted) {
        setState(() {
          _timedOut = true;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startTimeOutTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // Also cancel the timer to avoid memory problems
    _timedOutTimer?.cancel();
    super.dispose();
  }

  // Now we create a method to stop the timer,
  // This will execute when stream successfully delivers some data
  void _cancelTimeOutTimer() {
    _timedOutTimer?.cancel();
  }

  // This retry method will be used for both stream and time out errors
  void _retry() {
    setState(() {
      _timedOut = false;
      _streamKey =
          UniqueKey(); // Forces 'streamBuilder' to restart with fresh stream
    });
    _startTimeOutTimer(); // restart the timer count down
  }

  @override
  Widget build(BuildContext context) {
    // if(_timedOut){
    //   return Scaffold(
    //     resizeToAvoidBottomInset: true,
    //     appBar: AppBar(
    //       title: Text('All Requests', style: Theme.of(context).textTheme.titleMedium,),
    //       backgroundColor: AppColors.transparent,
    //     ),
    //     body: GeneralExceptionWidget(onPress: _retry, message: 'Connection timed out. \nPlease check your connection.'),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Requests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: AppColors.transparent,
      ),
      body: _timedOut
          ? GeneralExceptionWidget(
              onPress: _retry,
              message: 'Connection timed out. \nPlease check your connection.',
            )
          : StreamBuilder<List<BookingModel>>(
              key: _streamKey,
              stream: _service.getNurseBookings(widget.nurseId),
              builder: (context, snapshot) {
                // Cancel the timer if data arrives
                if (snapshot.hasData) {
                  _cancelTimeOutTimer();
                }
                // Show loading indicator while waiting for data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(color: AppColors.blueColor),
                  );
                }
                // Show error widget if data-fetch fails
                if (snapshot.hasError) {
                  return GeneralExceptionWidget(
                    onPress: _retry,
                    message: snapshot.error.toString(),
                  );
                }
                final List<BookingModel> bookings = snapshot.data ?? [];
                // If there is no data then,
                if (bookings.isEmpty) {
                  return Center(
                    child: Text(
                      'No bookings yet.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                  );
                }
                // Now return a listView
                return ListView.builder(
                  padding: EdgeInsets.all(22.r),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return RequestCardWidget(
                      booking: booking,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PatientDetailView(booking: booking),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
