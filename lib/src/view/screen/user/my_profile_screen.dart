// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:xchange_net/src/view/screen/user/update_profile_screen.dart';
// import 'package:xchange_net/src/view/widget/sign_in.dart';
// import '../../../../core/app_color.dart';
// import '../../widget/profile_menu.dart';
// import '../login_screen.dart';
// import 'faqs_screen.dart';
//
// final SignIn signIn = Get.put(SignIn());
// class MyProfileScreen extends StatefulWidget {
//   const MyProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MyProfileScreen> createState() => _MyProfileScreenState();
// }
//
// class _MyProfileScreenState extends State<MyProfileScreen> {
//   String? name;
//   String? email;
//   String? myimageurl;
//
//   @override
//   void initState() {
//     super.initState();
//     getNameFromSharedPreferences().then((value) {
//       setState(() {
//         name = value;
//       });
//     });
//     getEmailFromSharedPreferences().then((value) {
//       setState(() {
//         email = value;
//       });
//     });
//     getImageFromSharedPreferences().then((value) {
//       setState(() {
//         myimageurl = value;
//       });
//     });
//   }
//
//   Future<String?> getNameFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Set<String> keys = prefs.getKeys();
//     String? name = keys.contains('userName') ? prefs.getString('userName') : '';
//     return name;
//   }
//   Future<String?> getEmailFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Set<String> keys = prefs.getKeys();
//     String? email = keys.contains('userEmail') ? prefs.getString('userEmail') : '';
//     return email;
//   }
//   Future<String?> getImageFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Set<String> keys = prefs.getKeys();
//     String? myimageurl = keys.contains('userImageUrl') ? prefs.getString('userImageUrl') : '';
//     return myimageurl;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepOrange,
//         automaticallyImplyLeading: false,
//         // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.light_mode_outlined)),
//         title: Text("My Profile",
//         style: TextStyle(fontSize: 20,),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(5),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               SizedBox(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(100),
//                   child:   Image.network(myimageurl!,
//                     width: 100,
//                     height: 100,
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//         ),
//               const SizedBox(height: 30),
//               name != null
//               ?Text(
//                 name!,
//                 style: Theme
//                     .of(context)
//                     .textTheme
//                     .headline4,
//               ): CircularProgressIndicator(),
//               email != null
//               ?Text(
//                 email!,
//                 style: Theme
//                     .of(context)
//                     .textTheme
//                     .bodyText1,
//               ): CircularProgressIndicator(),
//               const SizedBox(height: 35),
//               SizedBox(
//                 width: 200,
//                 child: ElevatedButton(
//                   // onPressed: () => Get.to(() => const UpdateProfileScreen()),
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
//                       return UpdateProfileScreen();
//                     }));
//                   },
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.darkOrange,
//                       side: BorderSide.none,
//                       shape: const StadiumBorder()),
//                   child: const Text(
//                     "Edit Profile",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 20),
//               //MENU
//               ProfileMenuWidget(
//                   title: "FAQs", icon: Icons.question_answer, onPress: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => FAQScreen()),
//                 );
//               }),
//               // ProfileMenuWidget(
//               //     title: "Billing Details",
//               //     icon: Icons.navigate_next,
//               //     onPress: () {}),
//               // ProfileMenuWidget(
//               //     title: "User Management",
//               //     icon: Icons.navigate_next,
//               //     onPress: () {}),
//               // const Divider(),
//               // const SizedBox(height: 10),
//               // ProfileMenuWidget(
//               //     title: "Information",
//               //     icon: Icons.navigate_next,
//               //     onPress: () {}),
//               const Divider(),
//               ProfileMenuWidget(
//                 title: "Logout",
//                 icon: Icons.logout,
//                 textColor: Colors.red,
//                 endIcon: false,
//                 onPress: () {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text("Logout"),
//                         content: Text("Are you sure you want to logout?"),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text("Cancel"),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               signIn.signOutGoogle();
//                               Navigator.of(context).pushAndRemoveUntil(
//                                 MaterialPageRoute(builder: (context) {
//                                   return LoginScreen();
//                                 }),
//                                 ModalRoute.withName('/'),
//                               );
//                             },
//                             child: Text("Logout"),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xchange_net/src/view/screen/user/update_profile_screen.dart';
import 'package:xchange_net/src/view/widget/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../../../core/app_color.dart';
import '../../widget/profile_menu.dart';
import '../login_screen.dart';
import 'faqs_screen.dart';

final SignIn signIn = SignIn(); // Assuming SignIn doesn't require GetX

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String? name;
  String? email;
  String? myimageurl;

  @override
  void initState() {
    super.initState();
    getNameFromSharedPreferences().then((value) {
      setState(() {
        name = value;
      });
    });
    getEmailFromSharedPreferences().then((value) {
      setState(() {
        email = value;
      });
    });
    getImageFromSharedPreferences().then((value) {
      setState(() {
        myimageurl = value;
      });
    });
  }

  Future<String?> getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? name = keys.contains('userName') ? prefs.getString('userName') : '';
    return name;
  }

  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? email = keys.contains('userEmail') ? prefs.getString('userEmail') : '';
    return email;
  }

  Future<String?> getImageFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? myimageurl = keys.contains('userImageUrl') ? prefs.getString('userImageUrl') : '';
    return myimageurl;
  }

  Widget _buildUserRatings(String userEmail) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        var userDocument = userSnapshot.data!.docs[0];
        String userId = userDocument.id;

        // return StreamBuilder(
        //   stream: FirebaseFirestore.instance
        //       .collection('users')
        //       .doc(userId)
        //       .collection('ratings')
        //       .snapshots(),
        //   builder: (context, snapshot) {
        //     if (!snapshot.hasData) {
        //       return CircularProgressIndicator();
        //     }
        //
        //     var ratings = snapshot.data!.docs;
        //
        //     // Display the ratings given to the current user.
        //     if (ratings.isEmpty) {
        //       return Text("No ratings given to you.");
        //     }
        //
        //     return Column(
        //       children: ratings.map((rating) {
        //         // Display each rating here.
        //         return ListTile(
        //           // title: Text("Rating Value: ${rating['rating_value']}"),
        //           title: Text("Rating Value: {rating['rating_value']}"),
        //           // Add more rating information here...
        //         );
        //       }).toList(),
        //     );
        //   },
        // );
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('ratings')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            var ratings = snapshot.data!.docs;

            // Calculate the average rating value
            double averageRating = 0;
            int totalRatings = 0;

            for (var rating in ratings) {
              double ratingValue = rating['rating'] ?? 0;
              averageRating += ratingValue;
              totalRatings++;
            }

            if (totalRatings > 0) {
              averageRating /= totalRatings;
            }

            // Display the average rating
            return Column(
              children: [
                Text("Average Rating: ${averageRating.toStringAsFixed(2)}"),
                SizedBox(height: 20),
                if (ratings.isEmpty) Text("No ratings and comments."),
                ...ratings.map((rating) {
                  // Display each rating and comment here.
                  double ratingValue = rating['rating'] ?? 0;
                  String comment = rating['comment'] ?? "No comment";

                  return ListTile(
                    title: Text("Rating Value: $ratingValue"),
                    subtitle: Text("Comment: $comment"),
                    // Add more rating information here...
                  );
                }).toList(),
              ],
            );
          },
        );


      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        automaticallyImplyLeading: false,
        title: Text(
          "My Profile",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    myimageurl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              name != null
                  ? Text(
                name!,
                style: Theme.of(context).textTheme.headline4,
              )
                  : CircularProgressIndicator(),
              email != null
                  ? Text(
                email!,
                style: Theme.of(context).textTheme.bodyText1,
              )
                  : CircularProgressIndicator(),
              const SizedBox(height: 15),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return UpdateProfileScreen();
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkOrange,
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Divider(),
              const SizedBox(height: 3),
              // MENU
              ProfileMenuWidget(
                title: "FAQs",
                icon: Icons.question_answer,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FAQScreen()),
                  );
                },
              ),
              ProfileMenuWidget(
                title: "Logout",
                icon: Icons.logout,
                textColor: Colors.red,
                endIcon: false,
                onPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              signIn.signOutGoogle();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) {
                                  return LoginScreen();
                                }),
                                ModalRoute.withName('/'),
                              );
                            },
                            child: Text("Logout"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 3),
              const Divider(),
              Text(
                "Ratings",
                style: TextStyle(
                  fontSize: 18, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Make it bold if desired
                ),
              ),
              const SizedBox(height: 10),
              _buildUserRatings(email!),
            ],
          ),
        ),
      ),
    );
  }
}
