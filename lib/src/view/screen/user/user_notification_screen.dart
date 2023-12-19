import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_color.dart';
import '../../widget/sign_in.dart';

final SignIn signIn = Get.put(SignIn());

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  _UserNotificationScreenState createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  @override
  void initState() {
    inputData();
    print(uid);
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

  final CollectionReference _adminActions =
  FirebaseFirestore.instance.collection('userNotifications').doc("$uid").collection('notification');

  Future<void> _markAsRead(String documentId) async {
    await _adminActions.doc(documentId).update({
      'isRead': true,
    });
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
                            "User Name: " + documentSnapshot['reportedName'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          SizedBox(height: 1),
                          Text(
                            "Remarks: " + documentSnapshot['reportStatus'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                          SizedBox(height: 40),
                          if (tabIndex == 0) // Show buttons only in the "New" tab
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.mark_email_unread,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () async {
                                    await _markAsRead(documentSnapshot.id);
                                  },
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
          backgroundColor: AppColor.darkOrange,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            "User Notification",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: Colors.black,
            tabs: [
              Tab(
                child: Text(
                  'New',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Read',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _adminActions.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = streamSnapshot.data;
                final unresolvedData = data?.docs.where((doc) => doc['isRead'] == false).toList();

                return _buildNotificationList(unresolvedData ?? [], 0);
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _adminActions.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = streamSnapshot.data;
                final resolvedData = data?.docs.where((doc) => doc['isRead'] == true).toList();

                return _buildNotificationList(resolvedData ?? [], 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
