import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:project_uaf/resources/colors/colors.dart';

class CustomPhoneField extends StatelessWidget {
  final TextInputType keyboardType;
  final PhoneNumber? initialValue;
  final Function(PhoneNumber)? onChanged;
  final Function(PhoneNumber)? onSubmitted;
  final FormFieldSetter<PhoneNumber>? onSaved;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  const CustomPhoneField({
    super.key,
    required this.keyboardType,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true, this.focusNode, this.textInputAction, this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return PhoneFormField(
      keyboardType: keyboardType,
      initialValue: initialValue ?? PhoneNumber.parse('+92'),
      enabled: enabled,
      validator: PhoneValidator.compose([
        PhoneValidator.required(context),
        PhoneValidator.validMobile(context)
      ]),
      onChanged: onChanged,
      onSaved: onSaved,
      onSubmitted: onSubmitted,
      countrySelectorNavigator: const CountrySelectorNavigator.dialog(),
      isCountrySelectionEnabled: true,
      isCountryButtonPersistent: true,
      countryButtonStyle: const CountryButtonStyle(
        showDialCode: true,
        showDropdownIcon: true,
        showFlag: true,
        flagSize: 18,
      ),
      decoration: InputDecoration(
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        hintText: "Phone Number...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(
          color: AppColors.greyColor
        )),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.blueColor, width: 1.0),
        ),
      ),
    );
  }
}
