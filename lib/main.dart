import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_uaf/view/splash_view/splash_view.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Check If already initialized
  try{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseDatabase.instance.databaseURL='https://final-year-project-c208b-default-rtdb.firebaseio.com';
  }catch(e){
    if(e is FirebaseException && e.code== 'duplicate-app'){
      // Already initialized, safe to continue
    }
    else{
      rethrow;
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 810),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nurse Care Go',
          theme: ThemeData(
            fontFamily: 'Poppins',
            textTheme: TextTheme(
                bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
                titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.sp),
                titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)
            ),
            colorScheme: ColorScheme.light(
                primary: Colors.blue,
            ),
              textButtonTheme:TextButtonThemeData(
                  style:TextButton.styleFrom(
                      foregroundColor: Colors.blue
                  )
              )
          ),
          home: child,
        );
      },
      child: SplashView(),
    );
  }
}

