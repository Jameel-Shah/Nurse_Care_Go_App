import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  const CustomDropdownField({
    super.key,
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      validator: validator,
      style:Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),borderSide: BorderSide(
          color: Colors.grey
        )),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      initialValue: value,
    );
  }
}
