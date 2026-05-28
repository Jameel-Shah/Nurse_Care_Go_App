import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/custom_dropdown_field.dart';
import 'package:project_uaf/resources/components/custom_phone_field.dart';
import 'package:project_uaf/resources/components/location_button.dart';
import 'package:project_uaf/resources/components/profile_image_picker.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/resources/utils/utils.dart';
import 'package:project_uaf/services/auth_services.dart';
import 'package:project_uaf/view/auth_view/login_view/login_view.dart';
import 'package:project_uaf/resources/components/gender_radio_group.dart';
import 'package:project_uaf/view/auth_view/widgets/text_input_button.dart';
import 'package:project_uaf/view/nurse_view/nurse_main_view.dart';
import 'package:project_uaf/view/patient_view/patient_main_view.dart';
import '../../../resources/components/availability_radio_group.dart';
import '../../../resources/components/button_widget.dart';
import '../../../resources/components/custom_text_form_field.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthServices _authServices= AuthServices();
  String userType = 'Patient';
  // Variable to pass and store image in database
  File? _selectedImage;
  // variables for default location values
  double latitude = 0.0;
  double longitude = 0.0;
  //Variable to pass and store qualification in database
  String? qualification;
  List<String> qualifications = [
    "Diploma in Nursing",
    "BSc Nursing",
    "MSc Nursing",
    "Certified Nursing Assistant",
    "Licensed Practical Nurse",
    "Registered Nurse",
  ];
  // variable to pass and store qualification in database
  String? categorySpecialization;
  List<String> nurseCategories = [
    "General Care",
    "Elderly Care",
    "Child Care",
    "Post-Surgery Care",
    "Emergency Care",
  ];
String? provinceRegion;
List<String> provinceRegions=[
  'Punjab',
  'Sindh',
  'Khyber Pakhtunkhwa',
  'Balochistan',
  'Azad Jammu & Kashmir',
  'Gilgit-Baltistan'
];
  // initializing a location variable to use location's package
  final Location _location = Location();
  bool _isLoading = false;
  bool _loading = false;
  bool _passwordHidden = true;
  bool _confirmPasswordHidden = true;
  // A key to identify widgets in the whole form
  final _formKey = GlobalKey<FormState>();
  // Controllers to pass values in database
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _workPlaceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  // variable to pass and store phone number in database
  String? formattedNumber;
  // variable to to pass and store gender n database
  String? gender;
  String? availability;
  // FocusNodes to focus on each field
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _experienceFocusNode = FocusNode();
  final _workPlaceFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _feeFocusNode = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _workPlaceController.dispose();
    _cityController.dispose();
    _feeController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _addressFocusNode.dispose();
    _experienceFocusNode.dispose();
    _workPlaceFocusNode.dispose();
    _cityFocusNode.dispose();
    _feeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(22.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProfileImagePicker(
                      onPickedImage: (image) {
                          _selectedImage = image;
                      },
                    ),
                  ),
                  Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter Your Account Details',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select User Type',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.0,
                        children: ["Patient", "Nurse"].map((String type) {
                          final isSelected = userType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSelected,
                            showCheckmark: false,
                            selectedColor: AppColors.blueColor,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.whiteColor : AppColors.blueColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0.r),
                              side: BorderSide(
                                 color: isSelected ? AppColors.blueColor : AppColors.blueColor, // Border color
                                 width: 1.0,
                              )
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                userType = (selected ? type : null)!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.h),
                      // First name
                      CustomTextFormField(
                        focusNode: _firstNameFocusNode,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        hint: 'First Name..',
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
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
                      SizedBox(height: 8.h),
                      // Last Name
                      CustomTextFormField(
                        focusNode: _lastNameFocusNode,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        hint: 'Last Name..',
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
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
                      SizedBox(height: 8.h),
                      // Email
                      CustomTextFormField(
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        hint: 'Email Address...',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email address is required';
                          }
                          if (!EmailValidator.validate(value.trim())) {
                            return 'Please Enter a valid Email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.h),
                      // Phone Number
                      CustomPhoneField(
                        keyboardType: TextInputType.number,
                        focusNode: _phoneFocusNode,
                        textInputAction: TextInputAction.next,
                        onChanged: (PhoneNumber? number) {
                          formattedNumber= number?.international ?? '';
                        },
                        onSubmitted: (value)=> FocusScope.of(context).nextFocus(),
                      ),
                      SizedBox(height: 8.h),
                      // City
                      CustomTextFormField(
                        hint: 'City...',
                        controller: _cityController,
                        keyboardType: TextInputType.text,
                        focusNode: _cityFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
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
                      SizedBox(height: 8.h),
                      // Province
                      CustomDropdownField(hint: 'Province/Region...',
                        items: provinceRegions,
                        onChanged: (value){
                        setState(() {
                          provinceRegion= value;
                        });
                      },
                        validator: (value){
                          if(value == null) return 'Please select a province/region';
                          return null;
                        },
                      ),
                      SizedBox(height: 8.h,),
                      // Address
                      CustomTextFormField(
                        focusNode: _addressFocusNode,
                        textInputAction: TextInputAction.next,
                        hint: 'Address...',
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
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
                          final addressRegex = RegExp(
                            r"^[a-zA-Z0-9\s#\/,.-]+$",
                          );
                          if (!addressRegex.hasMatch(address)) {
                            return "Address contains invalid characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.h),
                      if (userType == "Nurse") ...[
                        // Gender
                        GenderRadioGroup(
                          selectedGender: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                        SizedBox(height: 8.h),
                        // Qualification
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
                              qualification = value;
                            });
                          },
                        ),
                        SizedBox(height: 8.h),
                        // Years of experience
                        CustomTextFormField(
                          hint: 'Years of Experience...',
                          controller: _experienceController,
                          focusNode: _experienceFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
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
                        SizedBox(height: 8.h),
                        // Category/Specialization
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
                              categorySpecialization = value;
                            });
                          },
                        ),
                        SizedBox(height: 8.h),
                        // Availability
                        AvailabilityRadioGroup(selectedAvailability: availability, onChanged: (value){
                          setState(() {
                            availability= value;
                          });
                        }),
                        SizedBox(height: 8.h,),
                        // Work place
                        CustomTextFormField(
                          focusNode: _workPlaceFocusNode,
                          textInputAction: TextInputAction.next,
                          hint: 'Hospital / Clinic (Optional)...',
                          controller: _workPlaceController,
                          keyboardType: TextInputType.text,
                          onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please Enter Where you work";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.h),
                        // Service fee
                        CustomTextFormField(hint: 'Service Fee...', controller: _feeController, keyboardType: TextInputType.number, focusNode: _feeFocusNode,onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(), suffixText: 'PKR/Hour', validator: (value){
                          if(value == null || value.isEmpty) return 'Enter fee';
                          if(int.tryParse(value) == null) return 'Enter a valid amount';
                          return null;
                        },)
                      ],
                      SizedBox(height: 8.h),
                      // Password
                      CustomTextFormField(
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.next,
                        hint: 'Password...',
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _passwordHidden,
                        onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordHidden = !_passwordHidden;
                            });
                          },
                          icon: Icon(
                            _passwordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        validator: (value) {
                          final trimmedValue = value?.trim() ?? "";
                          if (trimmedValue.isEmpty) {
                            return "Password is required";
                          }
                          if (trimmedValue.length < 8 ||
                              trimmedValue.length > 12) {
                            return "Password must be 8-12 characters";
                          }
                          final passwordRegex = RegExp(
                            r'[0-9!@#\$%^&*(),.?":{}|<>]',
                          );
                          if (!passwordRegex.hasMatch(trimmedValue)) {
                            return "Use at least one number or special character";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.h),
                      // Confirm password
                      CustomTextFormField(
                        focusNode: _confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        hint: 'Confirm Password...',
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _confirmPasswordHidden,
                        onFieldSubmitted: (_)=>_getLocation(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _confirmPasswordHidden = !_confirmPasswordHidden;
                            });
                          },
                          icon: Icon(
                            _confirmPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please re-enter your password";
                          }
                          // check if password matches the first password
                          if (value.trim() != _passwordController.text) {
                            return "Password does not match";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  LocationButton(
                    title: 'Click to Get Home or Work Location',
                    isLoading: _isLoading,
                    onTap: () => _getLocation(),
                  ),
                  if (latitude != 0.0 && longitude != 0.0)
                    Center(
                      child: Text(
                        'Location: ($latitude, $longitude)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  SizedBox(height: 12.h),
                  ButtonWidget(
                    title: 'Sign Up',
                    isLoading: _loading,
                    onTap: _register,
                  ),
                  SizedBox(height: 36.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextInputButton(
                        title: 'SignIn',
                        onPress: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Function to get user's current location
  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final locationData = await _location.getLocation();
      setState(() {
        latitude = locationData.latitude!;
        longitude = locationData.longitude!;
      });
    } catch (e) {
      Utils.showErrorMessage("Failed to get location");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 Future<void> _register()async{
    if(_formKey.currentState!.validate()){
      setState(() {
        _loading=true;
      });
      // Building the user data map here in the screen
      final userData= {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': formattedNumber,
        'city': _cityController.text.trim(),
        'provinceRegion': provinceRegion,
        'profileImageUrl': '',
        'address': _addressController.text.trim(),
        'latitude': latitude,
        'longitude': longitude,
        if(userType== 'Nurse')...{
          'gender': gender,
          'qualification': qualification,
          'yearsOfExperience': _experienceController.text.trim(),
          'categorySpecialization': categorySpecialization,
          'availability': availability,
          'workPlace': _workPlaceController.text.trim(),
          'serviceFee': double.tryParse(_feeController.text.trim()) ?? 0.0,
          'totalReviews': 0,
          'averageRating': 0.0,
        },
      };
      try{
        final role =await _authServices.registerUser(email: _emailController.text.trim(), password: _passwordController.text.trim(), userType: userType, userData: userData, imageFile: _selectedImage!=null ? File(_selectedImage!.path): null);
        // Getting current user id if registerUser method succeeds
        final String uid= FirebaseAuth.instance.currentUser!.uid;
        if(!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> role==UserRole.nurse? NurseMainView(nurseId: uid,): PatientMainView(patientId: uid,)), (Route<dynamic> route) => false);
        Utils.showSuccessMessage('Account created successfully');
      }on AppException catch(e){
        if(mounted) Utils.showErrorDialog(context: context, title: 'Error', message: e.message);
      }finally{
        if(mounted) {
          setState(() {
          _loading=false;
        });
        }
      }
    }
 }
}
