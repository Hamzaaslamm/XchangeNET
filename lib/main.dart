import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xchange_net/core/app_theme.dart';
import 'package:xchange_net/src/view/screen/admin/admin_screen.dart';
import 'package:xchange_net/src/view/screen/user/user_screen.dart';
import 'package:xchange_net/src/view/screen/login_screen.dart';
import 'package:xchange_net/src/view/screen/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  String? email;

  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? email = keys.contains('userEmail') ? prefs.getString('userEmail') : '';
    return email;
  }


  // Function to check if the user is already logged in using shared preferences
  Future<void> checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
    getEmailFromSharedPreferences().then((value) {
      setState(() {
        email = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            //To Remove the banner in right corner
              debugShowCheckedModeBanner: false,
              home: SplashScreen());
        } else {
          // Loading is done, return the app:
          return MaterialApp(
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
            ),
            //To Remove the banner in right corner
            debugShowCheckedModeBanner: false,
            // home: const HomeScreen(),
            theme: AppTheme.lightAppTheme,
            home: isLoggedIn
                ? email == 'dumytesst@gmail.com' ? AdminScreen() : UserScreen()
            // ? email == 'xchangenet037@gmail.com' ? AdminScreen() : UserScreen()
                : LoginScreen(),

            // home: isLoggedIn ? UserScreen() : LoginScreen(),
            // home: isLoggedIn ? AdminScreen() : LoginScreen(),
          );
        }
      },
    );
  }
}