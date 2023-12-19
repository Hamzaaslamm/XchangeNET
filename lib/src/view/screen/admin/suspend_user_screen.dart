import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../core/app_theme_admin.dart';
import '../../widget/sign_in.dart';

final SignIn signIn = Get.put(SignIn());

class SuspendUserScreen extends StatefulWidget {
  @override
  _SuspendUserScreenState createState() => _SuspendUserScreenState();
}

class _SuspendUserScreenState extends State<SuspendUserScreen> {
  List<DocumentSnapshot>? _suspendedListData; // List to store suspended users data

  @override
  void initState() {
    inputData();
    super.initState();
    // Fetch suspend users data and update the list
    fetchSuspendedUsersData();
  }

  String imageUrl = '';
  String? usersId;
  static String? uid;

  String? get getId {
    return uid;
  }

  void inputData() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
  }

  final CollectionReference _suspendedUsers =
  FirebaseFirestore.instance.collection('admin')
      .doc("$uid")
      .collection('suspendUsers');

  // Method to fetch suspend users data
  void fetchSuspendedUsersData() async {
    try {
      QuerySnapshot snapshot = await _suspendedUsers.get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _suspendedListData = snapshot.docs;
        });
      }
    } catch (e) {
      // Handle any errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
      color: isLightMode ? AppThemeAdmin.nearlyWhite : AppThemeAdmin.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor:
          isLightMode ? AppThemeAdmin.nearlyWhite : AppThemeAdmin.nearlyBlack,
          appBar: AppBar(
            backgroundColor: isLightMode ? Colors.white : AppThemeAdmin.dark_grey,
            title: Text(
              'Suspend User',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Suspended user cannot unsuspend",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildSuspendedUsersList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the list of suspend users
  Widget _buildSuspendedUsersList() {
    if (_suspendedListData != null && _suspendedListData!.isNotEmpty) {
      return ListView.builder(
        itemCount: _suspendedListData!.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot documentSnapshot = _suspendedListData![index];
          return Card(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(right: 60),
                      child: ClipOval(
                        child: Image.network(
                          documentSnapshot['reportedImageURL'],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            documentSnapshot['reportedName'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Reason: " + documentSnapshot['reportReason'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          "Suspend List Empty",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}