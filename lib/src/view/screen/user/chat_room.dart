import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'chat_screen.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  final String ratingUserUId;
  final String ratedUserUId;

  ChatRoom({required this.chatRoomId, required this.userMap,
    required this.ratingUserUId, required this.ratedUserUId,});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
      "isVisible": true,
    });

    var ref =
    FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
        "isVisible": true,
      };

      _message.clear();
// Data added to firestore (chatRoomId)
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
// Adding field to chatRoomId
      final chatRef = FirebaseFirestore.instance.collection('chatroom').doc(widget.chatRoomId);
      final chatData = {
        'ratingUserUId': widget.ratingUserUId,
        'ratedUserUId': widget.ratedUserUId,
      };
      await chatRef.set(chatData, SetOptions(merge: true));

    } else {
      print("Enter Some Text");
    }
  }
  
  // void showRatingDialog(BuildContext context, String ratingUserId, String ratedUserId) async {
  //   final CollectionReference _ratings = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(ratedUserId)
  //       .collection('ads');
  //   double rating = 3.0;
  //   String comment = "";
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Rate and Comment"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             RatingBar.builder(
  //               initialRating: rating,
  //               minRating: 1,
  //               direction: Axis.horizontal,
  //               allowHalfRating: true,
  //               itemCount: 5,
  //               itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  //               itemBuilder: (context, _) => Icon(
  //                 Icons.star,
  //                 color: Colors.amber,
  //               ),
  //               onRatingUpdate: (newRating) {
  //                 rating = newRating;
  //               },
  //             ),
  //             SizedBox(height: 10),
  //             TextField(
  //               maxLines: 2,
  //               decoration: InputDecoration(
  //                 hintText: "Add a comment...",
  //               ),
  //               onChanged: (value) {
  //                 comment = value;
  //               },
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Here, you can save the rating and comment to Firestore or perform any other desired action.
  //               // You can access `rating` and `comment` variables here.
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("Submit"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void showRatingDialog(BuildContext context, String ratingUserId, String ratedUserId) async {
      final CollectionReference _ratings = FirebaseFirestore.instance
          .collection('users')
          .doc(ratedUserId)
          .collection('ratings');
    double rating = 3.0;
    String comment = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rate and Comment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              SizedBox(height: 10),
              TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Add a comment (optional)",
                ),
                onChanged: (value) {
                  comment = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Document for the rating with a unique ID
                final newRatingDoc = _ratings.doc();
                // Map containing the rating data
                final ratingData = {
                  'rating_user_id': ratingUserId,
                  'rating': rating,
                  'comment': comment,
                  'timestamp': FieldValue.serverTimestamp(),
                  'rated_user_id': ratedUserId,
                };

                // Set the data in Firestore
                await newRatingDoc.set(ratingData);

                // Close the dialog
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: StreamBuilder<DocumentSnapshot>(
          stream:
          _firestore.collection("users").doc(widget.userMap['uid']).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              print("Status: ${widget.userMap['status']}");
              return Container(
                child: Column(
                  children: [
                    Text(widget.userMap['name'],
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      snapshot.data!['status'],
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              showRatingDialog(context, widget.ratingUserUId, widget.ratedUserUId);
            },
            child: Text(
              'Give Rating',
              style: TextStyle(color: Colors.white),
            ),
          ),
            // ElevatedButton(
            //   onPressed: () {
            //     showRatingDialog(context);
            //   },
            //   child: Text("Show Test Dialog"),
            // ),
          ClipOval(
            child: Container(
              height: 40.0, // Set a relative height
              width: 40.0, // Keep it square for a round shape
              child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Set a relative borderRadius
                ),
                icon: Icon(Icons.more_vert, color: Colors.white),
                elevation: 3,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            'Clear Chat',
                          ),
                        ],
                      ),
                    ),
                    // PopupMenuItem(
                    //   value: 'close',
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.close, color: Colors.black),
                    //       SizedBox(width: 10),
                    //       Text('Close Ad'),
                    //     ],
                    //   ),
                    //   onTap: () {
                    //     // Call the showRatingDialog method to display the AlertDialog
                    //     // showRatingDialog(context);
                    //     showTestDialog(context);
                    //   },
                    // ),
                  ];
                },
                onSelected: (value) async {
                  if (value == 'clear') {
                    // Delete all chat messages in the chatroom using the chatRoomId
                    Navigator.pop(context);
                    QuerySnapshot messagesSnapshot = await _firestore
                        .collection('chatroom')
                        .doc(widget.chatRoomId)
                        .collection('chats')
                        .get();

                    for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
                      await messageDoc.reference.delete();
                    }
                  }
                },
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        return messages(size, map, context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => getImage(),
                              icon: Icon(Icons.photo, color: Colors.deepOrange,),
                            ),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send), onPressed: onSendMessage, color: Colors.deepOrange,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    bool isSentByCurrentUser = map['sendby'] == _auth.currentUser!.displayName;
    Color messageColor = isSentByCurrentUser ? Colors.lightBlueAccent : Colors.black54;

    return map['type'] == "text"
        ? Container(
      width: size.width,
      alignment: isSentByCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: messageColor,
        ),
        child: Text(
          map['message'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    )
        : Container(
      height: size.height / 2.5,
      width: size.width,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      alignment: isSentByCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShowImage(
              imageUrl: map['message'],
            ),
          ),
        ),
        child: Container(
          height: size.height / 2.5,
          width: size.width / 2,
          decoration: BoxDecoration(border: Border.all()),
          alignment: map['message'] != "" ? null : Alignment.center,
          child: map['message'] != ""
              ? Image.network(
            map['message'],
            fit: BoxFit.cover,
          )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
