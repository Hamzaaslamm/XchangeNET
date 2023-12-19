import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_color.dart';
import '../../widget/sign_in.dart';

final SignIn signIn = Get.put(SignIn());

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  _AdminNotificationScreenState createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  @override
  void initState() {
    inputData();
    super.initState();
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

  final CollectionReference _userReports =
  FirebaseFirestore.instance.collection('adminNotifications');

  final CollectionReference _suspendedUsers =
  FirebaseFirestore.instance.collection('admin')
      .doc("$uid")
      .collection('suspendUsers');

  final CollectionReference _blockedUsers =
  FirebaseFirestore.instance.collection('admin')
      .doc("$uid")
      .collection('blockUsers');

  Future<void> _userNotification(String reporterId, String reportedName, String reportedImageURL, String reportStatus) async {
    await FirebaseFirestore.instance
        .collection('userNotifications')
        .doc(reporterId)
        .collection('notification')
        .add({
      'reportedName': reportedName,
      'reportedImageURL': reportedImageURL,
      'reportStatus': reportStatus,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
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


  Future<void> _suspendUser(String reportedName, String reportedImageURL, String reportReason, String reportedId) async {
    await _suspendedUsers.add({
      'reportedName': reportedName,
      'reportedImageURL': reportedImageURL,
      'reportReason': reportReason,
      'suspendedAt': DateTime.now(),
      'reportedId': reportedId,
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Suspended!')));
  }

  Future<void> _blockUser(String reportedName, String reportedImageURL, String reportReason, String reportedId) async {
    await _blockedUsers.add({
      'reportedName': reportedName,
      'reportedImageURL': reportedImageURL,
      'reportReason': reportReason,
      'suspendedAt': DateTime.now(),
      'reportedId': reportedId,
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Blocked!')));
  }

  Future<void> _markAsResolved(String documentId) async {
    await _userReports.doc(documentId).update({
      'isResolved': true,
    });
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
              .limit(5)
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
                Text("Average Rating: ${averageRating.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
  Widget _buildUserAvgRatings(String userEmail) {
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
              .limit(5)
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
                Text("Average Rating: ${averageRating.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationList(List<DocumentSnapshot> data, int tabIndex) {
    if (data.isNotEmpty) {
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot documentSnapshot = data[index];
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
                            "Reported User Name: " +
                                documentSnapshot['reportedName'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          // Text("Reported User ID: "+
                          //     documentSnapshot['reportedId'],
                          //   style: TextStyle(
                          //     fontSize: 15,
                          //   ),
                          // ),
                          SizedBox(height: 1),
                          Text(
                            "Reason: " + documentSnapshot['reportReason'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                          SizedBox(height: 10),
                          _buildUserRatings(documentSnapshot['reportedEmail']),
                          SizedBox(height: 10),
                          Divider(
                            height: 20,
                            color: Colors.black,
                          ),
                          Text(
                            "Reporter User Name: " +
                                documentSnapshot['reporterName'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10,),
                          _buildUserAvgRatings(documentSnapshot['reporterEmail']),
                          // Text(
                          //     DateFormat.MMMMEEEEd().format(documentSnapshot['publishAt'].toDate()).toString(),
                          //     style: TextStyle(
                          //       fontSize: 9,
                          //     ),
                          //     overflow: TextOverflow.ellipsis,
                          //     maxLines: 1,
                          //   ),
                          // Text("Reporter User ID: "+
                          //     documentSnapshot['reporterId'],
                          //   style: TextStyle(fontSize: 15),
                          // ),
                          if (tabIndex == 0) // Show buttons only in the "New" tab
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.dangerous_rounded,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm'),
                                          content: Text(
                                              'Are you sure you want to suspend this user?'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                AppColor.darkOrange,
                                              ),
                                              child: Text('Yes'),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await _suspendUser(
                                                  documentSnapshot['reportedName'],
                                                  documentSnapshot['reportedImageURL'],
                                                  documentSnapshot['reportReason'],
                                                  documentSnapshot['reportedId'],
                                                ); // Add to _suspendedUsers collection

                                                await _targetUserNotification(
                                                  documentSnapshot['reportedId'], // Pass the reportedId here
                                                  documentSnapshot['reportedName'],
                                                  documentSnapshot['reportedImageURL'],
                                                  'You have suspended and no longer part of XchangeNET',
                                                );//Notify the suspended user

                                                await _markAsResolved(documentSnapshot.id);
                                                await _userNotification(
                                                  documentSnapshot['reporterId'], // Pass the reporterId here
                                                  documentSnapshot['reportedName'],
                                                  documentSnapshot['reportedImageURL'],
                                                  'This user is suspended successfully',
                                                );
                                              },
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                AppColor.darkOrange,
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
                                ),
                                Text(
                                  'Suspend',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.block,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm'),
                                          content: Text(
                                              'Are you sure you want to block this user?'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                AppColor.darkOrange,
                                              ),
                                              child: Text('Yes'),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await _blockUser(
                                                  documentSnapshot['reportedName'],
                                                  documentSnapshot['reportedImageURL'],
                                                  documentSnapshot['reportReason'],
                                                  documentSnapshot['reportedId'],
                                                ); // Add to _blockedUsers collection

                                                await _targetUserNotification(
                                                  documentSnapshot['reportedId'], // Pass the reportedId here
                                                  documentSnapshot['reportedName'],
                                                  documentSnapshot['reportedImageURL'],
                                                  'You have blocked and contact admin to change your status',
                                                );//Notify the suspended user

                                                await _markAsResolved(documentSnapshot.id);
                                                await _userNotification(
                                                  documentSnapshot['reporterId'], // Pass the reporterId here
                                                  documentSnapshot['reportedName'],
                                                  documentSnapshot['reportedImageURL'],
                                                  'This user is blocked successfully',
                                                );
                                              },
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                AppColor.darkOrange,
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
                                ),
                                Text(
                                  'Block',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
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
          "No Notification!",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor:
          // AppColor.darkOrange,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            "Admin Notification",
            style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold,),
          ),
          bottom: TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                child: Text(
                  'New',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,),
                ),
              ),
              Tab(
                child: Text(
                  'Resolved',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _userReports.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = streamSnapshot.data;
                final unresolvedData = data?.docs
                    .where((doc) => doc['isResolved'] == false)
                    .toList();

                return _buildNotificationList(unresolvedData ?? [], 0);
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _userReports.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = streamSnapshot.data;
                final resolvedData = data?.docs
                    .where((doc) => doc['isResolved'] == true)
                    .toList();

                return _buildNotificationList(resolvedData ?? [], 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}