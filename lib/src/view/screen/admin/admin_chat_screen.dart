import 'package:flutter/material.dart';
import 'package:xchange_net/src/view/screen/admin/admin_chat_room.dart';
import '../../../../core/app_theme_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xchange_net/core/app_color.dart';

import 'admin_chat_notification_screen.dart';

class AdminChatScreen extends StatefulWidget {
  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> with WidgetsBindingObserver, TickerProviderStateMixin{
  int notificationCount = 0; // Counter variable for notifications

  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    inputData();
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
    // Fetch the notification count and update the counter variable
    fetchNotificationCount();
    // fetchAllDocuments();
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
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


  final CollectionReference _adminchat =
  FirebaseFirestore.instance.collection('admin').doc("$uid").collection('notification');



  // Method to fetch the notification count
  void fetchNotificationCount() async {
    final snapshot = await _adminchat.where('isRead', isEqualTo: false).get();
    setState(() {
      notificationCount = snapshot.docs.length;
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }



  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
      userMap = null; // Reset the userMap
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("User not found"),
              content: Text("No user with the provided email was found."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      //If user 1 send message to user 2.
      return "$user1$user2";
    } else {
      //If user 2 send message to user 1.
      return "$user2$user1";
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
      var brightness = MediaQuery
          .of(context)
          .platformBrightness;
      bool isLightMode = brightness == Brightness.light;
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor:
                isLightMode ? AppThemeAdmin.nearlyWhite : AppThemeAdmin.nearlyBlack,
                appBar: AppBar(
                  backgroundColor: isLightMode ? Colors.white : AppThemeAdmin
                      .dark_grey,
                  title: Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  actions: <Widget>[
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications),
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminChatNotificationScreen(),
                              ),
                            );
                          },
                        ),
                        if (notificationCount > 0) // Display the notification count badge if there are unread notifications
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notificationCount.toString(), // Replace with the actual number of notifications
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                body: isLoading
                    ? Center(
                      child: Container(
                        height: size.height / 20,
                        width: size.height / 20,
                      child: CircularProgressIndicator(),
        ),
      )
          : Column(
        children: [
          SizedBox(
            height: size.height / 20,
          ),
          Container(
            height: size.height / 14,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 14,
              width: size.width / 1.15,
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: "Enter email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: size.height / 50,
          ),
          ElevatedButton(
            onPressed: onSearch,
            child: Text("Search"),
          ),
          SizedBox(
            height: size.height / 30,
          ),
          // userMap != null
          //     ? ListTile(
          if (userMap != null)
            userMap!['email'] == _auth.currentUser!.email
                ? Text("You cannot chat with yourself",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
                : ListTile(

            onTap: () {
              String roomId = chatRoomId(
                _auth.currentUser!.displayName!,
                userMap!['name'],
              );
              // updateChatRoomId(roomId);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminChatRoom(
                    chatRoomId: roomId,
                    userMap: userMap!,
                  ),
                ),
              );
              _targetUserNotification(
                userMap!['uid'],
                _auth.currentUser!.displayName!,
                _auth.currentUser!.photoURL!,
                'You have received a message from Admin ' +
                    _auth.currentUser!.email!,
              );
            },
            leading: Icon(Icons.account_box, color: Colors.black),
            title: Text(
              userMap!['name'],
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(userMap!['email']),
            trailing: Icon(Icons.chat, color: Colors.black),
          ),
              // : Container(),
          Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 90, // Adjust the indent (left padding)
            endIndent: 90, // Adjust the end indent (right padding)
          ),
          Text(
            "Users List",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          Expanded(
            child:
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<Widget> userListWidgets = [];
                final users = snapshot.data!.docs;

                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  final userEmail = userData['email'] as String;

                  // Check if the current user's email matches the email of the user being processed
                  if (userEmail != _auth.currentUser!.email) {
                    userListWidgets.add(
                      ListTile(
                        onTap: () {
                          String roomId = chatRoomId(
                            _auth.currentUser!.displayName!,
                            userData['name'],
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminChatRoom(
                                chatRoomId: roomId,
                                userMap: userData,
                              ),
                            ),
                          );
                          _targetUserNotification(
                            userData['uid'],
                            _auth.currentUser!.displayName!,
                            _auth.currentUser!.photoURL!,
                            'You have received a message from Admin ' +
                                _auth.currentUser!.email!,
                          );
                        },
                        title: Text(
                          userData['name'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userData['email']),
                        trailing: Icon(Icons.chat, color: Colors.black),
                      ),
                    );
                  }
                }

                return ListView(
                  children: userListWidgets,
                );
              },
            ),

          ),
        ],
      ),
    );
  }
}