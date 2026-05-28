import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_uaf/model/booking_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/general_exception_widget.dart';
import 'package:project_uaf/resources/components/status_badge.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/nurse_booking_service.dart';
import 'package:project_uaf/view/patient_view/widgets/detail_row_widget.dart';

class BookingHistoryScreen extends StatefulWidget {
  final String patientId;
  const BookingHistoryScreen({super.key, required this.patientId});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
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

  // Now we create a method to stop the timer,
  // This will execute when stream successfully delivers some data
  void _cancelTimeOutTimer() {
    _timedOutTimer?.cancel();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // Also cancel the timer to avoid memory problems
    _timedOutTimer?.cancel();
    super.dispose();
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

  // Instance for using 'Booking Service' class
  final NurseBookingService _nurseBookingService = NurseBookingService();
  // Cancel logic
  Future<void> _cancelBooking(String bookingId) async {
    // First we show confirmation dialog before cancelling
    Utils.showConfirmationDialog(
      context: context,
      onPress: () async {
        try {
          await _nurseBookingService.cancelBooking(bookingId);
          if (mounted) Utils.showSuccessMessage('Booking cancelled successfully');
        } on AppException catch (e) {
          if (mounted) {
            Utils.showErrorDialog(
              context: context,
              title: 'Error',
              message: e.message,
            );
          }
        }
      },
      title: 'Are you sure you want to cancel this request?',
    );
  }

  // Now Delete logic
  Future<void> _deleteBooking(String bookingId) async {
    try {
      await _nurseBookingService.deleteBooking(bookingId);
    } on AppException catch (e) {
      if (mounted) {
        Utils.showErrorDialog(
          context: context,
          title: 'Error',
          message: e.message,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if(_timedOut){
    //   return Scaffold(
    //     resizeToAvoidBottomInset: true,
    //     appBar: AppBar(
    //       title: Text('My Bookings', style: Theme.of(context).textTheme.titleMedium,),
    //       backgroundColor: AppColors.transparent,
    //     ),
    //     body: GeneralExceptionWidget(onPress: _retry, message: 'Connection timed out. \nPlease check your connection.'),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
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
              key: _streamKey, // When this key changes, stream fully restarts
              stream: _nurseBookingService.getPatientBookings(widget.patientId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _cancelTimeOutTimer();
                }
                // --- Show loading indicator while waiting for data to appear on screen
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SpinKitFadingCircle(color: AppColors.blueColor);
                }
                // --- Show Exception widget if error occurs
                if (snapshot.hasError) {
                  final message = snapshot.error is AppException
                      ? (snapshot.error as AppException).message
                      : 'Something went wrong. Could not load data';
                  return GeneralExceptionWidget(
                    onPress: _retry,
                    message: message,
                  );
                }
                // If there is no booking data in Firebase then show text 'No bookings yet'
                final List<BookingModel> bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64.r,
                          color: AppColors.greyColor,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No bookings yet.',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.greyColor),
                        ),
                      ],
                    ),
                  );
                }
                // Now we display data using list-view builder because it renders each bookingModel as a Card
                // and displays those cards which are available
                return ListView.builder(
                  padding: EdgeInsets.all(22.r),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final BookingModel booking = bookings[index];
                    return _buildSlidableCard(booking);
                  },
                );
              },
            ),
    );
  }

  // --- Now it is time for slidable card
  Widget _buildSlidableCard(BookingModel booking) {
    // Whether this booking can still be cancelled
    final bool isPending = booking.status == 'pending';
    // Whether this booking can be deleted
    final bool isDeletable =
        booking.status == 'rejected' || booking.status == 'cancelled';
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Slidable(
        key: ValueKey(
          booking.bookingId,
        ), // Slidable always requires a unique key--- So, this time we passed booking id
        startActionPane: isDeletable
            ? ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25, // how much of card the action takes
                children: [
                  SlidableAction(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: AppColors.redColor,
                    foregroundColor: AppColors.whiteColor,
                    onPressed: (_) => _deleteBooking(booking.bookingId),
                  ),
                ],
              )
            : null, // We write null here because if booking/hiring request gets accepted by Nurse then there will be no swipe right/cancel action
        endActionPane: isPending
            ? ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (_) => _cancelBooking(booking.bookingId),
                    backgroundColor: AppColors.orangeColor,
                    foregroundColor: AppColors.whiteColor,
                    icon: Icons.cancel_outlined,
                    label: 'Cancel',
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              )
            : null, // We write null here because once the bookings/hiring request gets accepted by the Nurse then there will be no delete action
        child: _buildBookingCard(booking),
      ),
    );
  }

  // --- Now we build the booking card ---
  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      color: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- First top row: date + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.date,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                StatusBadge(status: booking.status),
              ],
            ),
            SizedBox(height: 8.h),
            // --- Now details
            // Time
            DetailRowWidget(icon: Icons.access_time, text: booking.time),
            // Hours
            DetailRowWidget(
              icon: Icons.timeline_outlined,
              text: '${booking.hours} hrs',
            ),
            DetailRowWidget(
              icon: Icons.attach_money,
              text: 'Rs. ${booking.totalFee.toStringAsFixed(0)}',
            ),
            // Description
            DetailRowWidget(
              icon: Icons.description_outlined,
              text: booking.description,
              maxLines: 5,
            ),
            SizedBox(height: 8.h),
            // --- Now we use hint text widget here for better UX
            _buildSwipHint(booking),
          ],
        ),
      ),
    );
  }

  // --- First we build a swip hint which tells the user which swip actions are available ---
  Widget _buildSwipHint(BookingModel booking) {
    if (booking.status == 'pending') {
      return Text(
        'Swipe right to cancel',
        style: TextStyle(fontSize: 11.sp, color: AppColors.greyColorShade400),
      );
    }
    if (booking.status == 'rejected' || booking.status == 'cancelled') {
      return Text(
        'Swipe left to delete',
        style: TextStyle(fontSize: 11.sp, color: AppColors.greyColorShade400),
      );
    }
    return const SizedBox.shrink(); // if request is accepted then no hint is needed
  }
}
