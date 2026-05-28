import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:project_uaf/resources/utils/error_handler.dart';

// Creating a class to upload image onto 'Cloudinary'
class CloudinaryService {
// Cloudinary credentials
static const String _cloudName= 'diuzohisu'; // cloud name from 'Cloudinary'
static const String _uploadPreset = 'nurse_care_go_app_preset'; //Unsigned-preset I created on 'Cloudinary'

//Method for uploading the image and returning the url
Future<String> uploadProfileImage({
    required File imageFile,
  required String userId,
   required String userType, // 'Nurse' or ''Patient
}) async{
  // print('>>> STEP 1: uploadProfileImage called');
  // print('>>> imageFile exists: ${imageFile.existsSync()}');
  // print('>>> imageFile path: ${imageFile.path}');
  try{
    // print('>>> STEP 2: starting compression');
    // Step 1 - Compress the image before uploading
    final compressedBytes = await _compressImage(imageFile);
    if(compressedBytes == null){
      throw AppException('Could not compress image. Please try another');
    }
    // print('>>> STEP 3: compression done — size: ${compressedBytes.length} bytes');

    // Step 2 - Build the upload URL
    final uri= Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    // print('>>> STEP 4: upload URI built: $uri');
    // Step 3 - build multipart request
    final request= http.MultipartRequest('Post', uri);
    // Step 4 - Add required fields
    request.fields['upload_preset']= _uploadPreset;
    // This sets the folder structure in Cloudinary: Nurses/uid or Patients/uid
    request.fields['public_id']= '$userType/$userId/profile';
    // Step 5 - Attach the compressed image bytes
    request.files.add(http.MultipartFile.fromBytes('file', compressedBytes, filename: 'profile.jpg'));
    // print('>>> STEP 5: request built, sending now...');
    // Step 6 - send the request with a timeout so it doesn't hang forever
    final streamedResponse= await request.send().timeout(Duration(seconds: 30), onTimeout: ()=> throw AppException('Upload time out. Please check your internet connection'));
    final responseBody= await streamedResponse.stream.bytesToString();
    // print('>>> STEP 6: response received');
    // print('>>> status code: ${streamedResponse.statusCode}');
    // print('>>> response body: $responseBody');
    if(streamedResponse.statusCode==200){
      // Step 7 - parse the response and return the image URL
      final json= jsonDecode(responseBody);
      final url= json['secure_url'] as String?;
      if(url==null) throw AppException('Upload succeeded but no URL returned');
      // print('>>> STEP 7: upload SUCCESS — url: $url');
      return  url;// This is the secure https image URL
    }else{
      // Log the full error to terminal so you can see what Cloudinary says
      // print('Cloudinary error response: $responseBody');
      final json= jsonDecode(responseBody);
      throw AppException(json['error']?['message']?? 'Image upload failed.');
    }
  } on AppException{
    rethrow; // Already clean
  } catch(e){
    // print('>>> CAUGHT ERROR: $e');
    throw AppException(ErrorHandler.parse(e));
  }
}

// Private helper method to compress image before uploading
Future<List<int>?> _compressImage(File imageFile) async{
  // print('>>> _compressImage called');
  try{
    final result= await FlutterImageCompress.compressWithFile(imageFile.absolute.path, quality: 80, minHeight: 400, minWidth: 400, format: CompressFormat.jpeg);
    return result;
  }catch(e){
    // print('>>> _compressImage ERROR: $e');
    rethrow;
  }
}


}