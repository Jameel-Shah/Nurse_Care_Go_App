// Creating a service class to handle all Firebase operations
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/services/cache_service.dart';
import 'package:project_uaf/services/chat_service.dart';
import 'package:project_uaf/services/cloudinary_service.dart';

enum UserRole { nurse, patient, unknown }

class AuthServices {
  // Creating an instance for Cloudinary service
  final CloudinaryService _cloudinary= CloudinaryService();
  //Creating instance for Firebase Auth to create patient and nurse account
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Creating Firebase Database instance to store patient or nurse details
  late final DatabaseReference _database = FirebaseDatabase.instance.ref();
  // Creating an instance to use cache service class
  final CacheService _cacheService= CacheService();
  // Creating an instance to sue chat service class
  final ChatService _chatService= ChatService();

  // Creating a method to register user
  Future<UserRole> registerUser({
    required String email,
    required String password,
    required String userType, // 'Nurse' or 'Patient'
    required Map<String, dynamic> userData, // fields from the form
    File? imageFile,
  }) async {
    // print('>>> AUTH STEP 1: registerUser called');
    // print('>>> email: $email');
    // print('>>> userType: $userType');
    // print('>>> imageFile is null: ${imageFile == null}');
    try {
      // Creating patient or nurse's account using email or password using Firebase Authentication
      // print('>>> AUTH STEP 2: creating Firebase Auth account');
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // print('>>> AUTH STEP 3: account created, uid: ${userCredential.user!.uid}');
      // Extract user object and extract user info like id
      final uid = userCredential.user!.uid;
      // Deciding the path where data will be stored
      final path = userType == 'Nurse' ? 'Nurses' : 'Patients';
      // print('>>> AUTH STEP 4: saving to database path: $path');

      // Now, we save user data with image url
      // First it will go either one of the databases, 'child(path)'
      // Then create a unique folder using user's id 'child(user.uid)'
      // Now save data inside set method
      // uid is used so every user has unique id
      await _database.child(path).child(uid).set({
        'uid': uid,
        'email': email,
        ...userData, //Now, we spread all the form fields data in
      });
      // print('>>> AUTH STEP 5: database write done');

      // print('>>> AUTH STEP 6: imageFile null check — is null: ${imageFile == null}');
      //Now, we write functionality to upload image into 'FirebaseStorage'
      if (imageFile != null) {
        // print('>>> AUTH STEP 7: calling uploadProfileImage');
        // Upload image to Cloudinary by using CloudinaryService class and get back a URL
        final imageUrl= await _cloudinary.uploadProfileImage(imageFile: imageFile, userId: uid, userType: path);
        // print('>>> AUTH STEP 8: got image url: $imageUrl');
        //Now, we save the uploaded image url into 'FirebaseDatabase'
        await _database.child(path).child(uid).update({'profileImageUrl': imageUrl});
        // print('>>> AUTH STEP 9: image url saved to database');
      }else{
        // print('>>> AUTH STEP 7: imageFile is null, skipping upload');
      }
      // print('>>> AUTH STEP 10: registration complete');
      // Register user id based on user type/role
      final role= userType == 'Nurse' ? UserRole.nurse : UserRole.patient;
      // also save id to cache memory
      await _cacheService.saveUserRole(role);
      // User has just created a account - So, they are now online
      await _chatService.setOnline(uid);
      // return id based on role/type
      return role;
    } catch (e) {
      // print('>>> AUTH ERROR: $e');
      // print('>>> AUTH STACK: $stack');
      // We re-throw as AppException so the UI gets a clean, readable message
      throw AppException(ErrorHandler.parse(e));
    }
  }

  // Method for user login
  Future<UserRole> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // First we login user with 'email and password' using Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Then we return and check the user who is trying to login by getting his / info based through id by using 'getUserRole' method
      final role= await getUserRole(userCredential.user!.uid);
      // save the id based on role into cache memory
      await _cacheService.saveUserRole(role);
      // After successful login set user's status to online
      await _chatService.setOnline(userCredential.user!.uid);
      // Return id based on role/user-type
      return role;
    } catch (e) {
      // We re-throw as AppException so the UI gets a clean, readable message
      throw AppException(ErrorHandler.parse(e));
    }
  }

  // For shared role check, we use this method
  Future<UserRole> getUserRole(String uid) async {
    // Fetching data from 'Nurses' database based on id
    final nurseSnap = await _database.child('Nurses').child(uid).get().timeout(const Duration(seconds: 8), onTimeout: ()=> throw AppException('No internet connection. Please check your network.'));
    // If the user who is trying to login exists in 'Nurses' database then return user role nurse
    if (nurseSnap.exists) return UserRole.nurse;
    // Similarly for patient
    final patientSnap = await _database.child('Patients').child(uid).get().timeout(const Duration(seconds: 8), onTimeout: ()=> throw AppException('No internet connection. Please check your network.'));
    if (patientSnap.exists) return UserRole.patient;
    // If none of nurse or patient exist then
    return UserRole.unknown;
  }

  // Logout function
  Future<void> logOutUser()async{
    try{
      final String? uid= _auth.currentUser?.uid;
      // Setting status offline before logging-out - after logging-out uid becomes null
      if(uid!=null){
        await _chatService.setOffline(uid);
      }
      // Logout by calling "signOut" method
      await _auth.signOut();
      // also clear cache memory,
      // So, A new user can login easily
      await _cacheService.clearCache();
    }catch(e){
      // We re-throw as AppException so the UI gets a clean, readable message
      throw AppException(ErrorHandler.parse(e));
    }
  }
}
