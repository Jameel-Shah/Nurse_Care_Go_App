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

### Database URL

Replace the database URL in `main.dart` with your own 
Firebase Realtime Database URL found in your Firebase console 
under **Realtime Database → Data tab**.
```dart
FirebaseDatabase.instance.databaseURL='https://final-year-project-c208b-default-rtdb.firebaseio.com';
```

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

## Screenshots

<img width="720" height="1600" alt="Splash_screen" src="https://github.com/user-attachments/assets/dd0ceebd-ec80-4224-baed-f7bf3d1190bf" />
<img width="720" height="1600" alt="Login_screen" src="https://github.com/user-attachments/assets/a0c46c1d-d7e0-427f-a0b8-c5d579fe12d2" />
<img width="720" height="1600" alt="Patient_Registration_screen_1sthalf" src="https://github.com/user-attachments/assets/689cb138-c028-45f1-8648-eaf771f64ee5" />
<img width="720" height="1600" alt="Patient_Registeration_Screen_2ndhalf" src="https://github.com/user-attachments/assets/824c2834-13c2-40ec-9b39-c2f73fa8a073" />
<img width="720" height="1600" alt="Nurse_registeration_Screen_1sthalf" src="https://github.com/user-attachments/assets/de5dee31-ecf1-4f15-93b2-66655b0f6c0d" />
<img width="720" height="1600" alt="Nurse_registeration_Screen_2ndhalf" src="https://github.com/user-attachments/assets/76369f0d-9a28-4785-8d69-1142094fead8" />
<img width="720" height="1600" alt="Patient_Home_Screen" src="https://github.com/user-attachments/assets/f37692a8-8472-4836-91b6-18da8d962d42" />
<img width="720" height="1600" alt="See_All_Nurses_Screen" src="https://github.com/user-attachments/assets/22c17c62-3e4d-46d6-8624-48020a84630c" />
<img width="720" height="1600" alt="Nurse_Details_View_!sthalf_Patiient_side" src="https://github.com/user-attachments/assets/fee1820e-24d4-43a2-80ec-e99bcb07bfac" />
<img width="720" height="1600" alt="Confirm Booking Screen" src="https://github.com/user-attachments/assets/c9396da2-e674-4143-b95f-66c6d77db6dc" />
<img width="720" height="1600" alt="Bookings_Screen_Patient_Side" src="https://github.com/user-attachments/assets/acd5de8e-1169-4cf4-a528-8d08dd2fde41" />
<img width="720" height="1600" alt="Patient_Profile_Screen" src="https://github.com/user-attachments/assets/080ad044-2ece-4f2e-aca7-969c5cec1e3e" />
<img width="720" height="1600" alt="Patient_Edit_Profile_Screen_1st_Half" src="https://github.com/user-attachments/assets/7786edae-9a5e-426b-85b6-a7c86c09beff" />
<img width="720" height="1600" alt="Patient_Edit_Profile_Screen_2nd_Half" src="https://github.com/user-attachments/assets/76f6f98f-58ae-4c68-b3f5-1cb8081a6668" />
<img width="720" height="1600" alt="Patient_Side_ChatList_Screen" src="https://github.com/user-attachments/assets/6c7c1cfa-e261-408b-ac89-389ab1b2a265" />
<img width="720" height="1600" alt="Chat_Screen" src="https://github.com/user-attachments/assets/1741762c-5fd2-47d3-a2d5-8d4a9a4a4ee7" />
<img width="720" height="1600" alt="Nurse_Home_Screen" src="https://github.com/user-attachments/assets/0e8b9a37-b885-4e4b-b7e2-8d612c010a0a" />
<img width="720" height="1600" alt="Patient_DetalView_Screen_Start" src="https://github.com/user-attachments/assets/6c5f7d1a-8f8d-4979-bcff-10db37c77f49" />
<img width="720" height="1600" alt="Patient_DetalView_Screen" src="https://github.com/user-attachments/assets/53c2609d-5086-4f46-9626-d4887ee068e7" />
<img width="720" height="1600" alt="Nurse_ChatList_Screen" src="https://github.com/user-attachments/assets/176a1fc8-94df-49a9-b2d1-602399188534" />
<img width="720" height="1600" alt="Nurse_Profile_Screen_1stHalf" src="https://github.com/user-attachments/assets/235fbef9-9522-46bc-ab59-85e72331254f" />
<img width="720" height="1600" alt="Nurse_Profile_screen" src="https://github.com/user-attachments/assets/3b57a8b0-50b6-4553-96e4-d90b2d49fa2f" />
<img width="720" height="1600" alt="Bookng_Requests_Screen_Nurse_Side" src="https://github.com/user-attachments/assets/8e24b2ef-d079-49a2-9478-22d74dd07b83" />
<img width="720" height="1600" alt="Nurse_Edit_Screen_1st_half" src="https://github.com/user-attachments/assets/d7775fb2-28f4-4d38-820f-08b2f8165a6f" />
<img width="720" height="1600" alt="Edit_Screen_3rd_half " src="https://github.com/user-attachments/assets/137d980a-1bc3-4185-88e7-ab26e10080f2" />
<img width="720" height="1600" alt="Edit_Screen_2nd_half" src="https://github.com/user-attachments/assets/596c60e8-f20d-4de4-a727-12228d6779f6" />

---

## Known Limitations

- Currently supports Pakistani phone number format
- Web support is limited (primarily built for Android)
- Chat feature requires both users to be registered
- Advanced state-management(Provider, GetX, Riverpod or Bloc) hasn't been used in this project yet
- This app does not have an admin pannel yet

---


## Author
** M Jameel Ur Rehman Shah**
Final Year Project - [University Of Agriculture Faisalabad]

---

## License

This project is for academic purposes only.

