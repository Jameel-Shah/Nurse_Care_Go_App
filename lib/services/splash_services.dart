//Creating a services class to check if the current user whether, they are nurse or patient logged in or not
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_uaf/resources/utils/error_handler.dart';
import 'package:project_uaf/services/auth_services.dart';
import 'package:project_uaf/services/cache_service.dart';
import 'package:project_uaf/services/chat_service.dart';

class SplashServices {
  //Instance for FirebaseAuth to connect to FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Creating an instance for 'AuthServices'
  final AuthServices _authServices = AuthServices();
  // Creating an instance so that we can use 'CacheServices'
  final CacheService _cacheService = CacheService();
  // Creating an instance for chat service class
  final ChatService _chatService = ChatService();
  // Method for checking the current logged in user
  Future<UserRole> checkAuthStatus() async {
    // Now, we wait for Firebase Auth to fully restore session
    // authStateChanges fires once with current user id after app restarts
    final user = await _auth.authStateChanges().first.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
    // Delay the operation for 2 seconds and show splash screen
    // await Future.delayed(Duration(seconds: 2));
    // Get the current user id
    // final user= _auth.currentUser;
    // If there is no user id or user logged in then return user role unknown and navigate to login screen
    if (user == null) return UserRole.unknown;
    // User is logged-in so we try get role/id from cache memory first
    final cacheRole = await _cacheService.getCachedRole();
    if (cacheRole != UserRole.unknown) {
      // User is already logged-in restore online
      _chatService.setOnline(user.uid).catchError((_) {});
      return cacheRole; // Navigation will happen even without internet
    }
    // cache memory is empty login in the user
    try {
      // return user id based on role/type by checking it with 'getUserRole' method
      final role = await _authServices.getUserRole(user.uid);
      // Also save the role/type into cache memory
      await _cacheService.saveUserRole(role);
      // User is verified from database restore online status
      _chatService.setOnline(user.uid).catchError((_) {});
      return role;
    } catch (e) {
      // If operation fails then throw errors to the UI
      throw AppException(ErrorHandler.parse(e));
    }
  }
}
