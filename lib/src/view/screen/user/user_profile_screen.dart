import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xchange_net/src/view/widget/sign_in.dart';
import '../../widget/profile_menu.dart';
import '../login_screen.dart';

final SignIn signIn = Get.put(SignIn());

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userImageURL;
  final String userName;
  final String userEmail;

  UserProfileScreen({
    required this.userId,
    required this.userImageURL,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userName;
  String? email;
  String? userImageURL;
  String reportReason = "";

  final _formKey = GlobalKey<FormState>(); // GlobalKey for the form

  @override
  void initState() {
    inputData();
    super.initState();
    getNameFromSharedPreferences().then((value) {
      setState(() {
        userName = value;
      });
    });
    getEmailFromSharedPreferences().then((value) {
      setState(() {
        email = value;
      });
    });
    getImageFromSharedPreferences().then((value) {
      setState(() {
        userImageURL = value;
      });
    });
  }

  String imageUrl = '';
  static String? uid;

  String? get getId {
    return uid;
  }

  void inputData() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
  }

  final CollectionReference _userReports =
  FirebaseFirestore.instance.collection('adminNotifications');

  Future<String?> getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    return userName;
  }

  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? email = keys.contains('userEmail') ? prefs.getString('userEmail') : '';
    return email;
  }

  Future<String?> getImageFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userImageURL = prefs.getString('userImageURL');
    return userImageURL;
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
        automaticallyImplyLeading: true,
        title: Text(
          "User Profile",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    widget.userImageURL,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              widget.userName != null
                  ? Text(
                widget.userName!,
                style:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
                  : CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 40),
              Form(
                key: _formKey, // Assign the GlobalKey to the form
                child: Column(
                  children: [
                    // Add a TextFormField here to get the report reason
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          reportReason = value;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a reason for reporting';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Reason for Reporting',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // MENU
                    ProfileMenuWidget(
                      title: "Report this User",
                      icon: Icons.report,
                      textColor: Colors.red,
                      endIcon: true,
                      onPress: () {
                        if (!_formKey.currentState!.validate()) {
                          return; // If the form is not valid, do nothing
                        }

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Report"),
                              content: Text("Are you sure you want to report?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (!reportReason.isEmpty) {
                                      await _userReports.add({
                                        "publishedAt": DateTime.now(),
                                        "reportReason": reportReason,
                                        "reporterId": uid,
                                        "reporterName": userName,
                                        "reportedId": widget.userId,
                                        "reportedName": widget.userName,
                                        "isResolved": false,
                                        "reportedImageURL": widget.userImageURL,
                                        "reportedEmail": widget.userEmail,
                                        "reporterEmail": email,
                                      });
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Reported!'),));
                                      // Clear the text field and navigate back
                                      _formKey.currentState!.reset();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text("Report"),
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
                    _buildUserRatings(widget.userEmail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
