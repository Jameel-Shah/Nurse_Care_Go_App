import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:project_uaf/model/nurse_model.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/button_widget.dart';
import 'package:project_uaf/resources/components/profile_image_picker.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/services/nurse_service.dart';
import '../../resources/components/availability_radio_group.dart';
import '../../resources/components/custom_dropdown_field.dart';
import '../../resources/components/custom_phone_field.dart';
import '../../resources/components/custom_text_form_field.dart';
import '../../resources/components/gender_radio_group.dart';
import '../../resources/components/location_button.dart';
import '../../resources/utils/utils.dart';
import '../../services/cloudinary_service.dart';

class NurseEditProfileView extends StatefulWidget {
  final NurseModel nurse;
  const NurseEditProfileView({super.key, required this.nurse});

  @override
  State<NurseEditProfileView> createState() => _NurseEditProfileViewState();
}

class _NurseEditProfileViewState extends State<NurseEditProfileView> {
  // --- variable for gender
  String? _gender;
  // --- variable for availability
  String? _availability;
  // variables for default location values
  double? _latitude;
  double? _longitude;
  // initializing a location variable to use location's package
  final Location _location = Location();
  // --- Form-key & patient service class instance
  final _formKey = GlobalKey<FormState>();
  final NurseService _nurseService = NurseService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  // --- Variable that will contain phone number from database and will be displayed in 'phone_form_field' widget
  String? _formattedNumber;
  PhoneNumber? _initialNumber;
  // --- TextEditingControllers with pre-filled data
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _experienceController;
  late final TextEditingController _workPlaceController;
  late final TextEditingController _feeController;
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
  //--- Variable to pass and store qualification in database
  String? _qualification;
  // --- List containing qualifications. These will be displayed in drop down widget
  List<String> qualifications = [
    "Diploma in Nursing",
    "BSc Nursing",
    "MSc Nursing",
    "Certified Nursing Assistant",
    "Licensed Practical Nurse",
    "Registered Nurse",
  ];
  // variable to pass and store qualification in database
  String? _categorySpecialization;
  // --- List containing categories/specializations. These will be displayed in drop down widget
  List<String> nurseCategories = [
    "General Care",
    "Elderly Care",
    "Child Care",
    "Post-Surgery Care",
    "Emergency Care",
  ];
  // FocusNodes to focus on each field
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _workPlaceFocusNode = FocusNode();
  final _experienceFocusNode = FocusNode();
  final _feeFocusNode = FocusNode();
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
    _firstNameController = TextEditingController(text: widget.nurse.firstName);
    _lastNameController = TextEditingController(text: widget.nurse.lastName);
    _formattedNumber = widget.nurse.phoneNumber;
    _initialNumber = PhoneNumber.parse(widget.nurse.phoneNumber);
    _qualification = widget.nurse.qualification;
    _categorySpecialization = widget.nurse.categorySpecialization;
    _gender = widget.nurse.gender;
    _cityController = TextEditingController(text: widget.nurse.city);
    _provinceRegion = widget.nurse.provinceRegion;
    _addressController = TextEditingController(text: widget.nurse.address);
    _experienceController = TextEditingController(
      text: widget.nurse.yearsOfExperience,
    );
    _workPlaceController = TextEditingController(text: widget.nurse.workPlace);
    _feeController = TextEditingController(
      text: widget.nurse.serviceFee.toStringAsFixed(0),
    );
    _availability = widget.nurse.availability;
    _longitude = widget.nurse.longitude;
    _latitude = widget.nurse.latitude;
  }

  bool _hasChanges() {
    // Check every field against patient data.
    final firstNameChanged =
        _firstNameController.text.trim() != widget.nurse.firstName;
    final lastNameChanged =
        _firstNameController.text.trim() != widget.nurse.lastName;
    final phoneNumberChanged = _formattedNumber != widget.nurse.phoneNumber;
    final cityChanged = _cityController.text.trim() != widget.nurse.city;
    final provinceChanged = _provinceRegion != widget.nurse.city;
    final addressChanged =
        _addressController.text.trim() != widget.nurse.address;
    final workPlaceChanged =
        _workPlaceController.text.trim() != widget.nurse.workPlace;
    final availabilityChanged = _availability != widget.nurse.availability;
    final feeChanged = _feeController.text.trim() != widget.nurse.serviceFee;
    final genderChanged = _gender != widget.nurse.gender;
    final qualificationChanged = _qualification != widget.nurse.qualification;
    final experienceChanged =
        _experienceController.text.trim() != widget.nurse.yearsOfExperience;
    final categorySpecializationChanged =
        _categorySpecialization != widget.nurse.categorySpecialization;
    final locationChanged =
        _latitude != widget.nurse.latitude ||
        _longitude != widget.nurse.longitude;
    final imageChanged = _newImageFile != null; // new image was picked
    return firstNameChanged ||
        lastNameChanged ||
        phoneNumberChanged ||
        cityChanged ||
        addressChanged ||
        locationChanged ||
        imageChanged ||
        provinceChanged ||
        workPlaceChanged ||
        genderChanged ||
        feeChanged ||
        qualificationChanged ||
        availabilityChanged ||
        workPlaceChanged ||
        experienceChanged ||
        categorySpecializationChanged;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _workPlaceController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _cityFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _workPlaceFocusNode.dispose();
    _feeFocusNode.dispose();
    _experienceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            "Edit Profile",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          backgroundColor: AppColors.transparent,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(22.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProfileImagePicker(
                      existingImageUrl: widget.nurse.profileImageUrl,
                      nameInitial: widget.nurse.firstName[0].toUpperCase(),
                      onPickedImage: (image) {
                        _newImageFile = image;
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
                  // Phone number
                  Text(
                    'Phone-Number',
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
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                  // Province/region
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
                      if (value == null)
                        return 'Please select a province/region';
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
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                  SizedBox(height: 12.h),
                  // Gender radio buttons
                  GenderRadioGroup(
                    selectedGender: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Qualification
                  Text(
                    'Qualification',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomDropdownField(
                    hint: 'Qualification...',
                    items: qualifications,
                    validator: (value) {
                      if (value == null) {
                        return "Please Select Qualification";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _qualification = value;
                      });
                    },
                    value: _qualification,
                  ),
                  SizedBox(height: 12.h),
                  // Category/Specialization
                  Text(
                    'Category/Specialization',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomDropdownField(
                    hint: 'Category / Specialization...',
                    items: nurseCategories,
                    validator: (value) {
                      if (value == null) {
                        return "Please select a category";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _categorySpecialization = value;
                      });
                    },
                    value: _categorySpecialization,
                  ),
                  SizedBox(height: 12.h),
                  // Years of experience
                  Text(
                    'Years of Experience',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Years of Experience...',
                    controller: _experienceController,
                    focusNode: _experienceFocusNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Experience";
                      }
                      if (int.parse(value) < 0) {
                        return "Invalid value";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Work place
                  Text(
                    'Work-Place',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    focusNode: _workPlaceFocusNode,
                    textInputAction: TextInputAction.next,
                    hint: 'Hospital / Clinic (Optional)...',
                    controller: _workPlaceController,
                    keyboardType: TextInputType.text,
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please Enter Where you work";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Availability
                  AvailabilityRadioGroup(
                    selectedAvailability: _availability,
                    onChanged: (value) {
                      setState(() {
                        _availability = value;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Service Fee
                  Text(
                    'Service/Hourly Fee',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Service Fee...',
                    controller: _feeController,
                    keyboardType: TextInputType.number,
                    focusNode: _feeFocusNode,
                    // onFieldSubmitted: (_) => _getLocation(),
                    suffixText: 'PKR/Hour',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter fee';
                      if (int.tryParse(value) == null)
                        return 'Enter a valid amount';
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
                      // 1. First Form validation
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
                      // 4. After Form submission sow confirmation dialog
                      Utils.showConfirmationDialog(
                        context: context,
                        onPress: _saveChangesNurse,
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

  // Function to get user's current location
  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });
    }
  }

  // // Method for saving changes made to the patient's profile
  Future<void> _saveChangesNurse() async {
    // Start loading
    setState(() {
      _isLoading = true;
    });
    try {
      // We are keeping existing image's url as default
      String imageUrl = widget.nurse.profileImageUrl;
      // We upload new image url to cloudinary
      if (_newImageFile != null) {
        imageUrl = await _cloudinaryService.uploadProfileImage(
          imageFile: _newImageFile!,
          userId: widget.nurse.uid,
          userType: "Nurses",
        );
      }
      // Now we update our data that we want to update in Firebase
      await _nurseService.updateNurse(
        nurseId: widget.nurse.uid,
        updatedNurseData: {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phoneNumber': _formattedNumber,
          'city': _cityController.text.trim(),
          'provinceRegion': _provinceRegion,
          'address': _addressController.text.trim(),
          'profileImageUrl': imageUrl,
          'gender': _gender,
          'qualification': _qualification,
          'categorySpecialization': _categorySpecialization,
          'yearsOfExperience': _experienceController.text.trim(),
          'workPlace': _workPlaceController.text.trim(),
          'availability': _availability,
          'serviceFee': _feeController.text.trim(),
          'latitude': _latitude,
          'longitude': _longitude,
        },
      );
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
}
