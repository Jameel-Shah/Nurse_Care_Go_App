# NurseCareGo - On Demmand Home Healthcare App 

A cross-platform mobile application built with Flutter and Firebase that bridges 
the gap between patients and qualified nurses for home healthcare services in Pakistan.

## About The Project

NurseCareGo allows patients to browse verified nurses, view their profiles, 
and send hiring requests based on their healthcare needs. Nurses can manage 
incoming requests, accept or reject bookings, and communicate with patients 
directly through the app.

This project was developed as a Final Year Project.

---

## Features

### Patient Side
- Register and login securely with email and password
- Browse a list of verified nurses with search and filter (gender, availability)
- View detailed nurse profiles including qualifications, years of expexperience and hourly rate etc
- Book a nurse by selecting date, time and number of hours
- Automatic total fee calculation based on hourly rate
- Real-time booking history with status updates (Pending, Accepted, Rejected)
- Cancel pending booking requests
- Chat with nurse directly through in-app messaging
- Call nurse via phone
- View nurse's work location on Google Maps
  
### Nurse Side  
- Register and login securely with email and password
- View dashboard with pending request count in real time
- Browse and manage all incoming hiring requests
- View detailed patient information before accepting
- Accept or reject booking requests with confirmation
- Chat with patient directly through in-app messaging
- Call patient via phone
- View patient's home location on Google Maps
  
### General
- Role-based navigation (Patient / Nurse)
- Real-time data updates using Firebase Realtime Database
- Secure Firebase Authentication
- Image upload via Cloudinary API
- Form validation throughout the app
- Graceful error handling with retry support
- Internet timeout detection on all screens
- Soft delete for booking records
  
---

## Tech Stack
* **Frontend:** [Flutter](https://flutter.dev) (UI Toolkit)
* **Backend:** [Firebase](https://firebase.google.com) (Auth, Realtime Database)
* **Language:** [Dart](https://dart.dev) 
* **State Management:** setState + StreamBuilder + FutureBuilder
* **Architecture:** Service Layer Pattern
---

### Getting Started

### Prerequisites
Make sure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/install) (3.x or above)
- [Android Studio](https://developer.android.com/studio/install) or [VS Code](https://code.visualstudio.com/download)
- A Firebase project set up at [console.firebase.google.com](https://console.firebase.google.com)
    
### Clone The Repository
```bash 
git clone https://github.com/Jameel-Shah/Nurse_Care_Go_App.git
```

### Firebase Setup

This project requires your own Firebase configuration. The `google-services.json` 
and `firebase_options.dart` files are excluded from this repository for security.

1. Go to [Firebase Console](https://console.firebase.google.com).
2. Create a new project
3. Add an Android app or an IOS app and download `google-services.json`
4. Place it in `android/app/`
5. Enable the following Firebase services:
   - Authentication (Email/Password)
   - Realtime Database

### Cloudinary Setup

This project uses Cloudinary for image uploads. 
The service file is excluded from this repository for security.
1. Create a free account at [cloudinary.com](https://cloudinary.com)
2. From your dashboard note your **Cloud Name**
3. Go to Settings → Upload → Add upload preset
4. Create a new preset and set it to **Unsigned**
5. Create the file `lib/services/cloudinary_service.dart`
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:project_uaf/resources/utils/error_handler.dart';

// Creating a class to upload image onto 'Cloudinary'
class CloudinaryService {
// Cloudinary credentials
static const String _cloudName= 'YOUR_CLOUD_NAME'; // cloud name from 'Cloudinary'
static const String _uploadPreset = 'YOUR_UPLOAD_PRESET'; //Unsigned-preset I created on 'Cloudinary'

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
```
### Firebase Database Rules

```json
{
  /* Visit https://firebase.google.com/docs/database/security to learn more about security rules. */
  "rules": {
    "Nurses":{
      ".read": "auth!=null", // logged in user(patients) can read nurse's data
      "$uid":{
        //".read": "auth!=null && auth.uid === $uid",
        ".write": "auth!=null && auth.uid === $uid"
      }
    },
      "Patients":{
        ".read": "auth!=null", // logged in user(nurses) can read patient's data
        "$uid":{
          //".read": "auth!=null && auth.uid === $uid",
    			".write": "auth!=null && auth.uid === $uid"
        }
      },
    "NurseBookings":{
      ".read": "auth!=null", // Only logged in users can access or read booking data
      ".indexOn": ["patientId", "nurseId"],
      "$bookingId":{
        // Patients can read their own bookings
        // nurse can read bookings assigned to them
        ".read": "auth!=null && (data.child('patientId').val()=== auth.uid || data.child('nurseId').val()=== auth.uid)",
          
          // only authenticad users can create a booking
          // patientId in data must match who is writing it
          // prevents a user from booking on behalf of someone else
          ".write": "auth!=null && (newData.child('patientId').val()=== auth.uid || data.child('patientId').val()=== auth.uid || data.child('nurseId').val()=== auth.uid)"
      }
    },
    // Rules for "Chats" database, Only logged in users can read and write messages
    "Chats":{
      ".read": "auth!=null", ".write": "auth!=null"
    },
    // Rules for "ChatList" database, only logged in users can see chat-lists
    "ChatList":{
      ".read": "auth!=null", ".write": "auth!=null"
    },
    // Rules for "Status" database, online or offline status will be set after successful login/registration
    "Status":{
      ".read": "auth!=null", ".write": "auth!=null"
    }
  }
}
```

### Install Dependencies

```bash
flutter pub get
```

### Run The App
```bash
flutter run
```

---

## Known Limitations

- Currently supports Pakistani phone number format
- Web support is limited (primarily built for Android)
- Chat feature requires both users to be registered

---


## Author
** M Jameel Ur Rehman Shah**
Final Year Project - [University Of Agriculture Faisalabad]

---

## License

This project is for academic purposes only.

