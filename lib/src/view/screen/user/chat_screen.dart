import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xchange_net/core/app_color.dart';
import 'chat_room.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatScreen> with WidgetsBindingObserver{

  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
    // fetchAllDocuments();
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  // void updateChatRoomId(String chatRoomId) async {
  //   await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
  //     "chatRoomId": chatRoomId,
  //   },
  //     SetOptions(merge: true),
  //   );
  // }


  //  void fetchAllDocuments() async {
  //   try {
  //     QuerySnapshot allDocs = await _firestore.collection("chatroom").get();
  //
  //     print("Total Documents: ${allDocs.docs.length}");
  //
  //     if (allDocs.docs.isNotEmpty) {
  //       for (QueryDocumentSnapshot docSnapshot in allDocs.docs) {
  //         print("Document Id: " + docSnapshot.id);
  //         Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  //         print("Document Data: " + data.toString());
  //       }
  //     } else {
  //       print("No documents found in the collection.");
  //     }
  //
  //     setState(() {
  //       // You can add any necessary state updates here
  //     });
  //   } catch (e) {
  //     print("Error fetching documents: $e");
  //   }
  // }



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

  Future<void> _targetAdminNotification(String reportedId, String reportedName, String reportedImageURL, String reportStatus) async {
    await FirebaseFirestore.instance
        .collection('admin')
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Screen",
        style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          // IconButton(icon: Icon(Icons.logout), onPressed: null
          //     // () => logOut(context)
          // )
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
                  userMap!['name']);
              String ratingUserUId = _auth.currentUser!.uid!;
              String ratedUserUId = userMap!['uid'];
              // updateChatRoomId(roomId);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoom(
                    chatRoomId: roomId,
                    userMap: userMap!,
                    ratingUserUId: ratingUserUId,
                    ratedUserUId: ratedUserUId,
                  ),
                ),
              );
              if (_search.text == "dumytesst@gmail.com") {
                _targetAdminNotification(
                  userMap!['uid'],
                  _auth.currentUser!.displayName!,
                  _auth.currentUser!.photoURL!,
                  'You have received a message from ' + _auth.currentUser!.email!,
                );
              } else {
                _targetUserNotification(
                  userMap!['uid'],
                  _auth.currentUser!.displayName!,
                  _auth.currentUser!.photoURL!,
                  'You have received a message from ' + _auth.currentUser!.email!,
                );
              }
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
          )
              // : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // _search.text = "xchangenet037@gmail.com"; // Set the search text
          _search.text = "dumytesst@gmail.com"; // Set the search text
          onSearch(); // Perform the search
          // Add your logic to handle the "Chat with Admin" button here
        },
        label: Text('Chat with Admin'),
        icon: Icon(Icons.chat),
        backgroundColor: AppColor.darkOrange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
