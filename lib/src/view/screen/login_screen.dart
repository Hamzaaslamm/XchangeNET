import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xchange_net/src/view/screen/user/user_screen.dart';
import 'admin/admin_screen.dart';
import 'user/all_product_screen.dart';

class LoginScreen extends StatefulWidget {


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? email;

  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? email = keys.contains('userEmail') ? prefs.getString('userEmail') : '';
    return email;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: size.width, // Use MediaQuery to get device width
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon.png',
                    width: size.width * 0.8, // Set image width to 80% of device width
                    height: size.height * 0.2, // Set image height to 20% of device height
                  ),
                  // SizedBox(height: size.height * 0.02), // Add vertical spacing based on device height
                  Text(
                    "Exchange Now",
                    style: TextStyle(
                      fontSize: size.width * 0.1, // Set font size based on device width
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      SignInButton(
                        Buttons.Google,
                        text: "Continue with Google",
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          // signIn.signInWithGoogle().then((result) {
                          //   if (result != null) {
                          //     Navigator.of(context).push(
                          //       MaterialPageRoute(
                          //         builder: (context) {
                          //           return UserScreen();
                          //         },
                          //       ),
                          //     );
                          //   }
                          // })
                          signIn.signInWithGoogle().then((result) {
                            if (result != null) {
                              getEmailFromSharedPreferences().then((value) {
                                setState(() {
                                  email = value;
                                });
                                if (email == 'dumytesst@gmail.com') {
                                // if (email == 'xchangenet037@gmail.com') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AdminScreen();
                                      },
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserScreen();
                                      },
                                    ),
                                  );
                                }
                              });
                            }
                          })
                              .whenComplete(() {
                            setState(() {
                              _isLoading = false;
                            });
                          });
                        },
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.02), // Add padding based on device width
            child: Text(
              "If you continue, you are accepting\nTerms & Conditions and Privacy",
              textAlign: TextAlign.center,
              // Set text style based on device width
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.grey[600],
              ),
            ),
          )
        ],
      ),
    );
  }
}