// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import '../../../../core/app_theme_admin.dart';
// import '../../widget/sign_in.dart';
//
// final SignIn signIn = Get.put(SignIn());
//
// class BlockUserScreen extends StatefulWidget {
//   @override
//   _BlockUserScreenState createState() => _BlockUserScreenState();
// }
//
// class _BlockUserScreenState extends State<BlockUserScreen> {
//   @override
//   void initState() {
//     inputData();
//     super.initState();
//   }
//
//   String imageUrl = '';
//   String? usersId;
//   static String? uid;
//
//   String? get getId {
//     return uid;
//   }
//
//   void inputData() {
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     final User? user = auth.currentUser;
//     uid = user?.uid;
//   }
//
//   final CollectionReference _blockedUsers =
//   FirebaseFirestore.instance.collection('admin')
//       .doc("$uid")
//       .collection('blockUsers');
//
//   @override
//   Widget build(BuildContext context) {
//     var brightness = MediaQuery.of(context).platformBrightness;
//     bool isLightMode = brightness == Brightness.light;
//     return Container(
//       color: isLightMode ? AppThemeAdmin.nearlyWhite : AppThemeAdmin.nearlyBlack,
//       child: SafeArea(
//         top: false,
//         child: Scaffold(
//           backgroundColor:
//           isLightMode ? AppThemeAdmin.nearlyWhite : AppThemeAdmin.nearlyBlack,
//           appBar: AppBar(
//             backgroundColor: isLightMode ? Colors.white : AppThemeAdmin.dark_grey,
//             title: Text(
//               'Block User',
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           body: Column(
//             children: <Widget>[
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Center(
//                     child: Text(
//                       'Block List Empty',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: isLightMode ? Colors.black : Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../core/app_theme_admin.dart';
import '../../widget/sign_in.dart';
import 'admin_screen.dart';

final SignIn signIn = Get.put(SignIn());

class BlockUserScreen extends StatefulWidget {
  @override
  _BlockUserScreenState createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends State<BlockUserScreen> {
  List<DocumentSnapshot>? _blockedListData; // List to store blocked users data

  @override
  void initState() {
    inputData();
    super.initState();
    // Fetch blocked users data and update the list
    fetchBlockedUsersData();
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

  final CollectionReference _blockedUsers =
  FirebaseFirestore.instance.collection('admin').doc("$uid").collection('blockUsers');

  // Method to fetch blocked users data
  void fetchBlockedUsersData() async {
    try {
      QuerySnapshot snapshot = await _blockedUsers.get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _blockedListData = snapshot.docs;
        });
      }
    } catch (e) {
      // Handle any errors here
    }
  }

  Future<void> _targetUserNotification(String reportedId, String reportedName, String reportedImageURL, String reportStatus) async {
    await FirebaseFirestore.instance
        .collection('userNotifications')
        .doc(reportedId)
        .collection('notification')
        .add({
      'reportedName': reportedName,
      'reportedImageURL': reportedImageURL,
      'reportStatus': reportStatus,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
              'Block User',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildBlockedUsersList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the list of blocked users
  Widget _buildBlockedUsersList() {
    if (_blockedListData != null && _blockedListData!.isNotEmpty) {
      return ListView.builder(
        itemCount: _blockedListData!.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot documentSnapshot = _blockedListData![index];
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm'),
                                        content:
                                        Text('Are you sure you want to unblock this user?'),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.deepOrange,
                                            ),
                                            child: Text('Yes'),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              unblockUser(documentSnapshot.id);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AdminScreen(),
                                                ),
                                              );
                                              await _targetUserNotification(
                                                documentSnapshot['reportedId'], // Pass the reporterId here
                                                documentSnapshot['reportedName'],
                                                documentSnapshot['reportedImageURL'],
                                                'You have unblocked and can enjoy feature of XchangeNET',
                                              );//Notify the suspended user
                                            },
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.deepOrange,
                                            ),
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.block,
                                  color: Colors.black54,
                                ),
                                label: Text(
                                  'Unblock',
                                  style: TextStyle(
                                    color: Colors.black, // Set the text color to black
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  primary: Colors.transparent, // Make the button background transparent
                                  padding: EdgeInsets.zero, // Remove padding around the icon and text
                                ),
                              ),
                            ],
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
          "Block List Empty",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  // Add the method to unblock the user
  void unblockUser(String documentId) async {
    try {
      // Access the Firestore document using the provided documentId
      DocumentReference documentRef = _blockedUsers.doc(documentId);
      // Delete the document (unblock the user)
      await documentRef.delete();
      // After deleting the document, update the list of blocked users
      fetchBlockedUsersData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User unblocked successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle any errors here
      print('Error unblocking user: $e');
    }
  }


}