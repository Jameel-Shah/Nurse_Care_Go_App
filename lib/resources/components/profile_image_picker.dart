import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_uaf/resources/colors/colors.dart';
import 'package:project_uaf/resources/components/image_bottom_sheet.dart';

class ProfileImagePicker extends StatefulWidget {
  final void Function(File pickedImage) onPickedImage;
  final String? existingImageUrl; // Existing image url
  final String? nameInitial; // If no image exist then we will use this to display letter
  const ProfileImagePicker({super.key, required this.onPickedImage, this.existingImageUrl, this.nameInitial});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  //Method for picking image from device's camera
  Future<void> _pickImageFromCamera() async {
    final cameraImage = await _picker.pickImage(source: ImageSource.camera);
    //Check if the variable is empty
    if (cameraImage == null) return;
    //Then assign the camera image as a path to '_imageFile' variable and Update UI via 'setState'.
    setState(() {
      _imageFile = File(cameraImage.path);
    });
    widget.onPickedImage(_imageFile!);

    //Making a 'Navigator.pop' to close the sheet
    if (mounted) Navigator.pop(context);
  }

  //Method for picking image from gallery
  Future<void> _pickImageFormGallery() async {
    final galleryImage = await _picker.pickImage(source: ImageSource.gallery);
    //Check if the variable is empty
    if (galleryImage == null) return;
    //Then assign the gallery image as a path to '_imageFile' variable and Update UI via 'setState'.
    setState(() {
      _imageFile = File(galleryImage.path);
    });
    widget.onPickedImage(_imageFile!);
    //Making a 'Navigator.pop' to close the sheet
    if (mounted) Navigator.pop(context);
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ImageBottomSheet(
          onCameraTap: _pickImageFromCamera,
          onGalleryTap: _pickImageFormGallery,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Now we decide what to show first:
    // 1) Image that is newly picked by user
    ImageProvider? imageProvider;
    // If user pick image image from device then it will be displayed, particularly on sign-Up screen or edit profile screen if image does not exist
    if(_imageFile!=null){
      // Pass it to 'imageProvider'
      imageProvider= FileImage(_imageFile!); // This is the new image picked from device
    }
    // If image url exists then
    else if(widget.existingImageUrl!=null && widget.existingImageUrl!.isNotEmpty){
      imageProvider= NetworkImage(widget.existingImageUrl!); // this is the image's url that will be displayed on edit screen if it is available
    }
    return GestureDetector(
      onTap: _showOptions,
      child: SizedBox(
        height: 140.h,
        width: 140.h,
        child: Stack(
          clipBehavior: Clip.none, // Allows the circle button overflow the stack
          children: [
            ClipOval(
                child: imageProvider!=null ? Image(image: imageProvider,  height: 140.h,width: 140.h, fit: BoxFit.cover,): Container(
                  height: 140.h,
                  width: 140.h,
                  color: const Color(0xffF0EFFF),
                  child: Center(
                    // We will display name's first letter if available, else  we will display icon
                    child: widget.nameInitial!=null && widget.nameInitial!.isNotEmpty? Text(widget.nameInitial!.toUpperCase(), style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 52.sp, color: AppColors.blueColor),): Icon(Icons.person, size: 40.r, color: AppColors.greyColor,),
                  ),
                )
            ),
            // Now Camera badge button at the bottom right
            Positioned(
              right: 0,
                bottom: 0,
                child: Container(
                  height: 36.r,
                  width: 36.r,
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: AppColors.whiteColor
                    )
                  ),
                  child: Icon(Icons.add_a_photo, color: AppColors.whiteColor, size: 18.r,),
                ),)
          ],
        ),
      ),
    );
  }
}
