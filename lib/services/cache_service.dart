import 'package:project_uaf/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Creating a role-key so, we can use it
static const String _roleKey= 'user_role';

// Method for saving user-role into cache memory after successful login or sign-up
Future<void> saveUserRole(UserRole role) async{
  // Creating an object/instance to use 'sharedPreferences'
  final prefs= await SharedPreferences.getInstance();
  // Now, we save the user-role by passing role-key and role to 'setString' method
  await prefs.setString(_roleKey, role.name);
}

// Method for reading cached-role/uid, which works offline
Future<UserRole> getCachedRole()async{
  // Creating an object/instance to use 'sharedPreferences'
  final prefs= await SharedPreferences.getInstance();
  // Now, we get the cached-role through 'getString' method
  final roleString= prefs.getString(_roleKey);
  switch(roleString){
    case 'nurse':
      return UserRole.nurse;
    case 'patient':
      return UserRole.patient;
      default:
        return UserRole.unknown;
  }
}

// Method for clearing cache on logout
Future<void> clearCache()async{
  // Creating an object/instance to use 'sharedPreferences'
  final prefs= await SharedPreferences.getInstance();
  // Also, remove role during logout
  await prefs.remove(_roleKey);
}


}