import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:project_uaf/model/nurse_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/button_widget.dart';
import 'package:project_uaf/resources/components/custom_text_form_field.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/nurse_booking_service.dart';
import 'package:project_uaf/view/patient_view/widgets/counter_tile_widget.dart';
import 'package:project_uaf/view/patient_view/widgets/picker_button.dart';

class ConfirmBookingView extends StatefulWidget {
  final NurseModel nurse;
  const ConfirmBookingView({super.key, required this.nurse});

  @override
  State<ConfirmBookingView> createState() => _ConfirmBookingViewState();
}

class _ConfirmBookingViewState extends State<ConfirmBookingView> {
  // Loading indicator
  bool _isLoading = false;
  // Variable to store data
  DateTime? _selectedDate;
  // variable to store time
  TimeOfDay? _selectedTime;
  // variable for total fees
  double _totalFee = 0.0; // It will be recalculated whenever hours change
  int _selectedHours = 1;
  // Declaring form key and controller
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocus = FocusNode();

  // Declaring an object for using 'NurseBookingService' class
  final NurseBookingService _bookingService = NurseBookingService();
  @override
  void dispose() {
    // TODO: implement dispose
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  // ---- Function to calculate fee ----
  // It is called every time the hours widget changes its state
  // Parses the input and multiplies by the nurse's hourly rate
  void _calculateFee() {
    setState(() {
      _totalFee = _selectedHours * widget.nurse.serviceFee;
    });
  }

  Future<void> _submitBooking() async {
    //  1. Format for storage
    final String date = DateFormat('MM/dd/yyyy').format(_selectedDate!);
    final String time = _selectedTime!.format(context);
    setState(() {
      _isLoading = true;
    });
    try {
      // 2.Delegate to booking service- throws AppException on failure
      await _bookingService.bookNurse(
        nurseId: widget.nurse.uid,
        date: date,
        time: time,
        hours: _selectedHours,
        totalFee: _totalFee,
        description: _descriptionController.text.trim(),
      );
      // 3.Showing success Dialog
      if (mounted) {
        Utils.showBookingSuccessDialog(
          context: context,
          message: 'Booking request sent successfully',
          onOkPress: ()=> Navigator.popUntil(context, (route)=> route.isFirst),
        );
      }
    } on AppException catch (e) {
      // 4. Clean app-level or Firebase errors
      if (mounted) {
        Utils.showErrorDialog(
          context: context,
          title: 'Booking Failed',
          message: e.message,
        );
      }
    } finally {
      // 7. Always runs and stops loading animation whether the operation succeeds or fails
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Confirm Booking',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          backgroundColor: AppColors.transparent,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(22.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNurseHeader(),
                SizedBox(height: 24.h),
                _buildDateTimePickers(),
                SizedBox(height: 16.h),
                _buildHoursField(),
                SizedBox(height: 16.h),
                _buildFeeDisplay(),
                SizedBox(height: 16.h),
                _buildDescriptionField(),
                SizedBox(height: 4.h,),
                _buildDescriptionLengthCounter(),
                SizedBox(height: 16.h),
                ButtonWidget(
                  title: 'Confirm Booking',
                  isLoading: _isLoading,
                  onTap: () {
                    // 1. First we do form validation
                    if (!_formKey.currentState!.validate()) return;
                    // 2. Now we handle manual validation for both date&time pickers
                    if (_selectedDate == null) {
                      Utils.showErrorDialog(
                        context: context,
                        title: 'Missing-info',
                        message: 'Please select a date',
                      );
                      return;
                    }
                    // Similarly for time
                    if (_selectedTime == null) {
                      Utils.showErrorDialog(
                        context: context,
                        title: "Missing-info",
                        message: "Please select time",
                      );
                      return;
                    }
                    // 3. After validation show confirmation dialog
                    Utils.showConfirmationDialog(
                      context: context,
                      onPress: _submitBooking,
                      title: 'Are you sure you want to hire this nurse?'
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---Nurse Header
  Widget _buildNurseHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundImage: widget.nurse.profileImageUrl.isNotEmpty
              ? NetworkImage(widget.nurse.profileImageUrl)
              : null,
          child: widget.nurse.profileImageUrl.isEmpty
              ? Text(
                  widget.nurse.firstName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20.h,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins'
                  ),
                )
              : null,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.nurse.firstName} ${widget.nurse.lastName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 5.h),
            Text(
              'Rs. ${widget.nurse.serviceFee.toStringAsFixed(0)}/hr',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.blueColor),
            ),
          ],
        ),
      ],
    );
  }

  // --- Now Date Time picker buttons, which are side by side
  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: PickerButton(
            label: _selectedDate == null
                ? 'Select Date'
                : DateFormat('MM/dd/yyyy').format(_selectedDate!),
            icon: Icons.calendar_today,
            onPress: _selectDate,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PickerButton(
            label: _selectedTime == null
                ? 'Select Time'
                : _selectedTime!.format(context),
            icon: Icons.access_time,
            onPress: _selectTime,
          ),
        ),
      ],
    );
  }

  // --- Method for building Data picker ---
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- Method for building time picker
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // --- Description Field
  Widget _buildDescriptionField() {
    return CustomTextFormField(
      hint: 'Describe your requirements...',
      controller: _descriptionController,
      keyboardType: TextInputType.text,
      maxLines: 3,
      focusNode: _descriptionFocus,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please add a description.';
        if (value.trim().length < 20) return 'Description too short (min 20 characters)';
        if(value.trim().length > 150) return 'Description too long (max 150 characters)';
        return null;
      },
    );
  }
  
  Widget _buildDescriptionLengthCounter(){
    return ValueListenableBuilder(valueListenable: _descriptionController, builder: (context, value, child){
      final int count= value.text.trim().length;
      return Text('$count/150',
        textAlign:TextAlign.right,
        style: TextStyle(
        fontSize: 14.sp,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        // counter will turn red when limit is approached --- It is a good UX practice
        color: count>= 150 ? AppColors.redColor : AppColors.greyColor
      ),);
    });
  }

  // Now the hours field
  Widget _buildHoursField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CounterTileWidget(
        title: 'Number of Hours',
        value: _selectedHours,
        onIncrement: () {
          // Always not go above 24
          if (_selectedHours < 24) {
            setState(() {
              _selectedHours++;
              _calculateFee();
            });
          }
        },
        onDecrement: () {
          // Always cannot go below
          if (_selectedHours > 1) {
            setState(() {
              _selectedHours--;
              _calculateFee();
            });
          }
        },
      ),
    );
  }

  // Fee display widget
  Widget _buildFeeDisplay() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blueColor2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueColor3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fee Summary', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hourly fee', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                'PKR. ${widget.nurse.serviceFee.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hours', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '$_selectedHours hrs',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Divider(color: AppColors.blueColor3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Fee',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'PKR. ${_totalFee.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
