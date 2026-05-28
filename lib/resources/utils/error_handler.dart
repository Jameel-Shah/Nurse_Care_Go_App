import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception{
  final String message;
  const AppException(this.message);
}

class ErrorHandler {
  static String parse(Object e){
    // Firebase-Auth errors - most specific, check first
    if(e is FirebaseAuthException){
        switch(e.code){
          case 'user-not-found':
            return 'No account found with this email.';
          case 'wrong-password':
            return 'Incorrect password. Please try again.';
          case 'email-already-in-use':
            return 'An account with this email already exists.';
          case 'weak-password':
            return 'Password must be at least 8 characters long.';
          case 'invalid-email':
            return 'Please enter a valid email address.';
          case 'too-many-requests':
            return 'Too many attempts. Please wait a moment and try again.';
          case 'network-request-failed':
            return 'No internet connection. Please check your network.';
          default:
            return 'Authentication error: ${e.message ?? e.code}';
        }
    }
     // Firebase general errors (database, storage, etc)
    if(e is FirebaseException){
      if(e.code== 'permission-denied'){
        return 'You do not have permission to perform this action.';
      }
      return 'A server error occurred. Please try again.';
    }

    // Internet / socket errors
    if(e is SocketException){
      return 'No internet connection. Please check your network and try again.';
    }

    // Timeout error
    if(e is TimeoutException){
      return 'Connection timed out. \nPlease check your connection & try again.';
    }
    // app-level errors (throw deliberately)
    if(e is AppException) return e.message;

    // Fallback or anything unexpected
    return 'Something went wrong. Please try again.';
  }
}