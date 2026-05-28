import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:project_uaf/model/patient_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/button_widget.dart';
import 'package:project_uaf/resources/components/location_button.dart';
import 'package:project_uaf/resources/components/profile_image_picker.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/cloudinary_service.dart';
import 'package:project_uaf/services/patient_service.dart';
import '../../resources/components/custom_dropdown_field.dart';
import '../../resources/components/custom_phone_field.dart';
import '../../resources/components/custom_text_form_field.dart';

class PatientEditProfileView extends StatefulWidget {
  final PatientModel patient;
  const PatientEditProfileView({super.key, required this.patient});

  @override
  State<PatientEditProfileView> createState() => _PatientEditProfileViewState();
}

class _PatientEditProfileViewState extends State<PatientEditProfileView> {
  // variables for default location values
  double? _latitude;
  double? _longitude;
  // initializing a location variable to use location's package
  final Location _location = Location();
  // --- Form-key & patient service class instance
  final _formKey = GlobalKey<FormState>();
  final PatientService _patientService = PatientService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  // --- Variable that will contain phone number from database and will be displayed in 'phone_form_field' widget
  String? _formattedNumber;
  PhoneNumber? _initialNumber;
  // --- TextEditingControllers with pre-filled data
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  // --- Variable 'provinceRegion' to store or pre-fill provinceRegion dropdown
  String? _provinceRegion;
  // --- List containing provinces & regions. These will be displayed in drop down widget
  List<String> provinceRegions = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Azad Jammu & Kashmir',
    'Gilgit-Baltistan',
  ];
  // FocusNodes to focus on each field
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  // --- variable to store image if user picks new
  File? _newImageFile;
  // --- variable for loading indicator
  bool _isLoading = false;
  bool _isLocationLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // This is how we pre-fill fields and drop-downs with existing data
    _firstNameController = TextEditingController(
      text: widget.patient.firstName,
    );
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _formattedNumber = widget.patient.phoneNumber;
    _initialNumber = PhoneNumber.parse(widget.patient.phoneNumber);
    _cityController = TextEditingController(text: widget.patient.city);
    _provinceRegion = widget.patient.provinceRegion;
    _addressController = TextEditingController(text: widget.patient.address);
    _longitude = widget.patient.longitude;
    _latitude = widget.patient.latitude;
  }
  bool _hasChanges(){
    // Check every field against patient data.
    final firstNameChanged= _firstNameController.text.trim()!= widget.patient.firstName;
    final lastNameChanged= _firstNameController.text.trim()!= widget.patient.lastName;
    final phoneNumberChanged= _formattedNumber!= widget.patient.phoneNumber;
    final cityChanged= _cityController.text.trim()!= widget.patient.city;
    final provinceChanged= _provinceRegion!= widget.patient.city;
    final addressChanged= _addressController.text.trim()!= widget.patient.address;
    final locationChanged= _latitude != widget.patient.latitude || _longitude!= widget.patient.longitude;
    final imageChanged= _newImageFile!=null; // new image was picked
    return firstNameChanged || lastNameChanged|| phoneNumberChanged|| cityChanged|| addressChanged|| locationChanged|| imageChanged || provinceChanged;
  }
  // --- Also dispose the data
  @override
  void dispose() {
    // TODO: implement dispose
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _cityFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          title: Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(22.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Image-Picker
                  Center(
                    child: ProfileImagePicker(
                      existingImageUrl: widget.patient.profileImageUrl,
                      nameInitial: widget.patient.firstName[0].toUpperCase(),
                      onPickedImage: (image) {
                        _newImageFile =
                            image; // Image is stored locally on device
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // First name
                  Text(
                    'First-Name',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    focusNode: _firstNameFocusNode,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    hint: 'First Name..',
                    controller: _firstNameController,
                    keyboardType: TextInputType.name,
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "First name is required";
                      }
                      // Checking for minimum length
                      if (value.trim().length < 2) {
                        return "Name is too short";
                      }
                      // Checking for maximum length
                      if (value.trim().length > 50) {
                        return "First Name cannot exceed 50 characters";
                      }
                      // This Regex allows letters, spaces, hyphens, and apostrophes
                      final nameRegExp = RegExp(r"^[a-zA-Z\s'-]+$");
                      if (!nameRegExp.hasMatch(value)) {
                        return 'Enter a valid first name (letters only)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Last name
                  Text(
                    'Last-Name',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    focusNode: _lastNameFocusNode,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    hint: 'Last Name..',
                    controller: _lastNameController,
                    keyboardType: TextInputType.name,
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Last name is required";
                      }
                      // Checking for maximum length
                      if (value.trim().length > 50) {
                        return "Last Name cannot exceed 50 characters";
                      }
                      // This Regex allows letters, spaces, hyphens, and apostrophes
                      final nameRegExp = RegExp(r"^[a-zA-Z\s'-]+$");
                      if (!nameRegExp.hasMatch(value.trim())) {
                        return 'Enter a valid last name (letters only)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Phone Number
                  Text(
                    'Phone Number',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomPhoneField(
                    initialValue: _initialNumber,
                    keyboardType: TextInputType.number,
                    focusNode: _phoneFocusNode,
                    textInputAction: TextInputAction.next,
                    onChanged: (PhoneNumber? number) {
                      _formattedNumber = number?.international ?? '';
                    },
                    // onSubmitted: (value) => FocusScope.of(context).nextFocus(),
                  ),
                  SizedBox(height: 12.h),
                  // City
                  Text('City', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'City...',
                    controller: _cityController,
                    keyboardType: TextInputType.text,
                    focusNode: _cityFocusNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "City is required";
                      }

                      if (value.length < 2) {
                        return "Enter a valid city";
                      }

                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return "City can only contain letters";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Province/Region
                  Text(
                    'Province/Region',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomDropdownField(
                    hint: 'Province/Region...',
                    items: provinceRegions,
                    onChanged: (value) {
                      setState(() {
                        _provinceRegion = value;
                      });
                    },
                    value: _provinceRegion,
                    validator: (value) {
                      if (value == null) return 'Please select a province/region';
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Address
                  Text(
                    'Address',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    focusNode: _addressFocusNode,
                    textInputAction: TextInputAction.next,
                    hint: 'Address...',
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    // onFieldSubmitted: (_) => _getLocation(),
                    validator: (value) {
                      final address = value?.trim() ?? '';
                      if (address.isEmpty) return "Home address is required";
                      // Minimum length check for a realistic address;
                      if (address.length < 10) {
                        return "Please enter a more detailed address";
                      }
                      // Maximum length check (e.g., 255 for database safety)
                      if (address.length > 255) {
                        return "Address is too long (max 255 chars)";
                      }
                      // 3. Regex allowing: letters, numbers, spaces, and # / , . -
                      final addressRegex = RegExp(r"^[a-zA-Z0-9\s#\/,.-]+$");
                      if (!addressRegex.hasMatch(address)) {
                        return "Address contains invalid characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  LocationButton(
                    title: 'Click to update location',
                    isLoading: _isLocationLoading,
                    onTap: () => _getLocation(),
                  ),
                  if (_latitude != 0.0 && _longitude != 0.0)
                    Center(
                      child: Text(
                        'Location: ($_latitude, $_longitude)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  SizedBox(height: 16.h),
                  ButtonWidget(
                    title: 'Save Changes',
                    isLoading: _isLoading,
                    onTap: () {
                      // 1. Form validation
                      if (!_formKey.currentState!.validate()) return;
                      // 2. Now we handle manual validation for province dropdown & location
                      if (_latitude == null || _longitude == null) {
                        Utils.showErrorDialog(
                          context: context,
                          title: 'Missing-Info',
                          message: 'Please select yor location',
                        );
                        return;
                      }
                      // 3. Check if anything actually changed
                      if(_hasChanges()){
                        Utils.showErrorDialog(context: context, title: 'No Changes', message: 'You have not made any changes to your profile.');
                        return;
                      }
                      // 4. After form submission show confirmation dialog
                      Utils.showConfirmationDialog(
                        context: context,
                        onPress: _saveChanges,
                        title: 'Are you sure you want to update your profile?',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method for saving changes made to the patient's profile
  Future<void> _saveChanges() async {
    // Start loading
    setState(() {
      _isLoading = true;
    });
    try {
      // We are keeping the old image url as default
      String imageUrl = widget.patient.profileImageUrl;
      // We upload new image to cloudinary,
      if (_newImageFile != null) {
        imageUrl = await _cloudinaryService.uploadProfileImage(
          imageFile: _newImageFile!,
          userId: widget.patient.uid,
          userType: 'Patients',
        );
      }
      // Now we update our data that we want to update in Firebase
      await _patientService.updatePatient(
        patientId: widget.patient.uid,
        updatedPatientData: {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phoneNumber': _formattedNumber,
          'city': _cityController.text.trim(),
          'provinceRegion': _provinceRegion,
          'address': _addressController.text.trim(),
          'profileImageUrl': imageUrl,
          'latitude': _latitude,
          'longitude': _longitude,
        },
      );
      // Now we show success message
      Utils.showSuccessMessage("Your Profile is updated successfully");
      if (!mounted) return;
      Navigator.pop(context);
    } on AppException catch (e) {
      Utils.showErrorDialog(
        context: context,
        title: 'Error',
        message: e.message,
      );
    } finally {
      // Always runs and stops loading animation whether the operation succeeds or fails
      setState(() {
        _isLoading = false;
      });
    }
  }

  //Function to get user's current location
  Future<void> _getLocation() async {
    setState(() {
      _isLocationLoading = true;
    });
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _latitude = locationData.latitude!;
        _longitude = locationData.longitude!;
      });
    } catch (e) {
      Utils.showErrorMessage("Failed to get location");
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }
}
