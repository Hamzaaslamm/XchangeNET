import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:xchange_net/src/view/screen/user/user_profile_screen.dart';
import '../../../../core/app_color.dart';
import 'ad_promotion_screen.dart';
import 'chat_screen.dart';

class AdDetailScreen extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final String exchangeWith;
  final String category;
  final String condition;
  final String value;
  final String userId;
  final String userName;
  final String userEmail;
  final String userImageURL;
  final String adId;

  AdDetailScreen({
    required this.image,
    required this.title,
    required this.description,
    required this.exchangeWith,
    required this.category,
    required this.condition,
    required this.value,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userImageURL,
    required this.adId,
  });

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  bool _isCurrentUser = false;

  @override
  void initState() {
    inputData();
    super.initState();
  }

  static String? uid;

  String? get getId {
    return uid;
  }

  void inputData() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
    setState(() {
      _isCurrentUser = uid == widget.userId;
    });
  }

  final CollectionReference _userAds = FirebaseFirestore.instance
      .collection('users')
      .doc("$uid")
      .collection('favoriteAds');

  final CollectionReference _closeAds = FirebaseFirestore.instance
      .collection('users')
      .doc("$uid")
      .collection('closeAds');

  Future<void> _shareAd() async {
    try {
      String adLink = 'https://www.xchangenet.com.pk/ads/id-10672934'; // replace with your ad link
      Share.share(adLink);
    } catch (e) {
      print("Error sharing ad: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            "Ad Detail",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareAd,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Image.network(
              widget.image,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title: " + widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  "Description: " + widget.description,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                ),
                Text(
                  "Category: " + widget.category,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "Condition: " + widget.condition,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "Value: " + widget.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isCurrentUser)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkOrange,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text("Favorite"),
                        onPressed: () async {
                          bool confirmFavorite = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm"),
                                content: Text("Are you sure you want to add to the favorite list?"),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.darkOrange,
                                    ),
                                    child: Text("Yes"),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.darkOrange,
                                    ),
                                    child: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmFavorite) {
                            await _userAds.add({
                              "title": widget.title,
                              "description": widget.description,
                              "exchangeWith": widget.exchangeWith,
                              "category": widget.category,
                              "condition": widget.condition,
                              "image": widget.image,
                              "value": widget.value,
                              "publishedAt": DateTime.now(),
                              "isPublished": true,
                              "isPromoted": false,
                              "userId": widget.userId,
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Added!'),
                            ));
                          }
                        },
                      ),
                    if (_isCurrentUser)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkOrange,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.all(10),
                        ),
                        child: const Text("Promote Ad"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdPromotionScreen(
                                image: widget.image,
                                title: widget.title,
                                description: widget.description,
                                exchangeWith: widget.exchangeWith,
                                category: widget.category,
                                condition: widget.condition,
                                value: widget.value,
                                userId: widget.userId,
                                userName: widget.userName,
                                email: widget.userEmail,
                                userImageURL: widget.userImageURL,
                                adId: widget.adId,
                              ),
                            ),
                          );
                        },
                      ),
                    SizedBox(width: 20,),
                    if (_isCurrentUser)
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: AppColor.darkOrange,
                      //     side: BorderSide.none,
                      //     shape: const StadiumBorder(),
                      //     padding: const EdgeInsets.all(10),
                      //   ),
                      //   child: const Text("Close Ad"),
                      //   onPressed: () {
                      //   },
                      // ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkOrange,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.all(10),
                        ),
                        child: const Text("Close Ad"),
                        onPressed: () async {
                          bool confirmClose = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm"),
                                content: Text("Are you sure you want to close this ad?"),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.darkOrange,
                                    ),
                                    child: Text("Yes"),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.darkOrange,
                                    ),
                                    child: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmClose) {
                            await FirebaseFirestore.instance.collection('ads')
                                .doc(widget.adId)
                                .delete();

                            // Create a new ad in the _closeAds collection
                            await _closeAds.add({
                              "title": widget.title,
                              "description": widget.description,
                              "exchangeWith": widget.exchangeWith,
                              "category": widget.category,
                              "condition": widget.condition,
                              "image": widget.image,
                              "value": widget.value,
                              "publishedAt": DateTime.now(),
                              "isPublished": false,
                              "isPromoted": false,
                              "userId": widget.userId,
                              "email": widget.userEmail,
                              "userName": widget.userName,
                            });

                            Navigator.of(context).pop(); // Close the current ad detail screen
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Ad closed successfully'),
                            ));
                          }
                        },
                      ),
                    if (!_isCurrentUser) SizedBox(width: 20),
                    if (!_isCurrentUser)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkOrange,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text("Negotiate"),
                        onPressed: () {
                          // Now, navigate to the ChatScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                              ),
                            ),
                          );
                        },
                      ),
                    if (!_isCurrentUser) SizedBox(width: 20),
                    // if (!_isCurrentUser)
                    //   ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: AppColor.darkOrange,
                    //       side: BorderSide.none,
                    //       shape: const StadiumBorder(),
                    //       padding: const EdgeInsets.all(10),
                    //     ),
                    //     child: const Text("Send Offer"),
                    //     onPressed: () {
                    //       // Now, navigate to the ChatScreen
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => ChatScreen(
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                  ],
                ),
                SizedBox(height: 5),
                if (!_isCurrentUser)
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                if (!_isCurrentUser)
                  GestureDetector(
                    onTap: () {
                      // Handle the click event here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: widget.userId,
                            userImageURL: widget.userImageURL,
                            userName: widget.userName,
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            widget.userImageURL,
                            height: 70, // Adjust the height as needed
                            width: 70, // Adjust the width as needed
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.userEmail,
                                      style: Theme.of(context).textTheme.headline4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: widget.userEmail));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Email copied to clipboard'),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}