import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/model/booking_model.dart';
import 'package:project_uaf/model/nurse_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/services/nurse_booking_service.dart';
import 'package:project_uaf/view/nurse_view/nurse_request_screen.dart';
import 'package:project_uaf/view/nurse_view/widgets/nurse_header.dart';
import 'package:project_uaf/view/patient_view/patient_detail_view.dart';
import 'package:project_uaf/view/patient_view/widgets/request_card_widget.dart';
import '../../resources/components/general_exception_widget.dart';
import '../../resources/utils/states.dart';
import '../../services/nurse_service.dart';

class NurseHomeView extends StatefulWidget {
  final String nurseId;
  const NurseHomeView({super.key, required this.nurseId});

  @override
  State<NurseHomeView> createState() => _NurseHomeViewState();
}

class _NurseHomeViewState extends State<NurseHomeView> {
  //--Services Classes instances---
  final NurseService _nurseService = NurseService();
  final NurseBookingService _nurseBookingService = NurseBookingService();
  // Loading indicator for whole screen
  PageState _pageState = PageState.loading;
  // variable to store error messages
  String _errorMessage = '';
  // Creating one shared timeout timer for streams
  Timer? _streamTimer;
  bool _streamTimedOut = false;
  // Initializing a unique key that will help restart both streams
  Key? _counterStreamKey = UniqueKey();
  Key? _requestStreamKey = UniqueKey();

  NurseModel? _nurse;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamTimer?.cancel();
    super.dispose();
  }

  // Making a timer function
  void _startStreamTimer() {
    // cancel any existing timer before staring a new one,
    // also this helps prevents multiple timers running in the background
    _streamTimer?.cancel();
    _streamTimer = Timer(const Duration(seconds: 8), () {
      // This will execute if stream fails to deliver data
      if (mounted) {
        setState(() {
          _streamTimedOut = true;
        });
      }
    });
  }

  // Method for cancelling the timer
  void _cancelStreamTimer() {
    _streamTimer?.cancel();
  }

  // Now retry function used for both StreamBuilders
  void _retryStream() {
    setState(() {
      _streamTimedOut = false;
      _counterStreamKey = UniqueKey(); // restarts both StreamBuilder
      _requestStreamKey = UniqueKey();
    });
    _startStreamTimer();
  }

  // Making a load data method which calls both patient and nurse service class using Future.wait
  // Which is much faster then calling them one after another
  Future<void> _loadData() async {
    // Reset state to loading when retrying
    setState(() {
      _pageState = PageState.loading;
    });
    try {
      final result =
          await Future.wait([
            _nurseService.fetchNurseById(widget.nurseId),
          ]).timeout(
            Duration(seconds: 8),
            onTimeout: () => throw AppException(
              'Connection timed out. \nPlease check your connection & try again.',
            ),
          );
      setState(() {
        _nurse = result[0];
        // Screen loaded fine
        _pageState = PageState.success;
      });
      // We will start stream-timer after nurse data is successfully loaded
      // There is no point in starting timer on streams if screen itself fails to load
      _startStreamTimer();
    } on AppException catch (e) {
      // Set error if exception happens like internet or Firebase
      setState(() {
        _errorMessage = e.message;
        _pageState = PageState.error;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fail to load, Please try again';
        _pageState = PageState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_pageState) {
      PageState.loading => const Center(
        child: SpinKitFadingCircle(color: Colors.blue, size: 50),
      ),
      PageState.error => GeneralExceptionWidget(
        onPress: _loadData,
        message: _errorMessage,
      ),
      PageState.success => _buildHomeWidget(),
    };
  }

  Widget _buildHomeWidget() {
    if (_streamTimedOut) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(22.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            NurseHeader(
              nurse: _nurse!,
            ), // it will be still visible because of the '_loadData'
            SizedBox(height: 24.h),
            // This will appear when stream fails to fetch data after timeout
            GeneralExceptionWidget(
              onPress: _retryStream,
              message:
                  'Connection timed out. \nPlease check your connection & try again.',
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          NurseHeader(nurse: _nurse!),
          SizedBox(height: 24.h),
          _buildPendingCounter(),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incoming Requests',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NurseRequestScreen(nurseId: widget.nurseId),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.blueColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildIncomingRequestsSection(),
        ],
      ),
    );
  }

  // Now, we design the pending counter
  Widget _buildPendingCounter() {
    return StreamBuilder<List<BookingModel>>(
      key: _counterStreamKey, // restarts when '_retryStream()' is called
      stream: _nurseBookingService.getNurseBookings(widget.nurseId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _cancelStreamTimer(); // If data arrives from stream then stop the timer
        }
        // Now we count only pending bookings
        final int pendingCount = snapshot.hasData
            ? snapshot.data!.where((b) => b.status == 'pending').length
            : 0;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.blueColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending Requests',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '$pendingCount',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
              Text(
                pendingCount == 1
                    ? 'Request waiting for your response'
                    : 'Request waiting for your response',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: AppColors.whiteColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Now we build and design the requests listview
  Widget _buildIncomingRequestsSection() {
    return StreamBuilder(
      key: _requestStreamKey,
      stream: _nurseBookingService.getNurseBookings(widget.nurseId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _cancelStreamTimer();
        }
        // Show loading indicator while data is being fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitFadingCircle(color: AppColors.blueColor));
        }

        // Show error widget if stream-fetch fails
        if (snapshot.hasError) {
          return GeneralExceptionWidget(
            onPress: _retryStream,
            message: snapshot.error.toString(),
          );
        }
        // Now we filter out only pending requests and pass them into the list, because this list will be passed into 'itemCount',
        // Also we are going to show 4 requests max
        final List<BookingModel> pendingBookings = (snapshot.data ?? [])
            .where((b) => b.status == 'pending')
            .take(4)
            .toList();
        if (pendingBookings.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 24.h),
              child: Text(
                'No Incoming requests.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.greyColor),
              ),
            ),
          );
        }
        // We are using 'ListView.builder' inside 'SingleChildScrollView'.
        // The 'shrinkWrap: true' makes ListView take only needed heigh.
        // 'physics: NeverScrollableScrollPhysics' does not allow scrolling of listView
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingBookings.length,
          itemBuilder: (context, index) {
            return RequestCardWidget(
              booking: pendingBookings[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PatientDetailView(booking: pendingBookings[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
