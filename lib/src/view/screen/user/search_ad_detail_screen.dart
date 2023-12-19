import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:xchange_net/src/view/screen/user/user_profile_screen.dart';

import '../../../../core/app_color.dart';
import 'ad_promotion_screen.dart';
import 'chat_screen.dart';

class SearchAdDetailScreen extends StatefulWidget {
  @override
  _SearchAdDetailScreenState createState() => _SearchAdDetailScreenState();
}

class _SearchAdDetailScreenState extends State<SearchAdDetailScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchText = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search',
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ads')
            .where('title', isGreaterThanOrEqualTo: searchText)
            .where('title', isLessThan: searchText + 'z')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) =>
                ListTile(
              title: Text(document['title']),
              subtitle: Column(
                children: [
                  // Image.network(
                  //   document['image'],
                  //   height: 200,
                  //   width: 200,
                  //   // fit: BoxFit.contain,
                  // ),
                  // Text(document['description']),
                  Text(document['category']),
                  // Text(document['condition']),
                  // Text(document['value'].toString()),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(document),
                  ),
                );
              },
            )
            ).toList(),
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final DocumentSnapshot document;

  DetailScreen(this.document);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
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
      _isCurrentUser = uid == widget.document['userId'];
    });
  }

  final CollectionReference _userAds = FirebaseFirestore.instance
      .collection('users')
      .doc("$uid")
      .collection('favoriteAds');

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
              "Search Ad Detail",
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
              widget.document['image'],
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
                      widget.document['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 5),
                  Text(
                      "Description: " + widget.document['description'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  Text(
                      "Category: " + widget.document['category'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  Text(
                      "Condition: " + widget.document['condition'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  Text(
                      "Exchange With: " + widget.document['exchangeWith'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  Text(
                      "Value: " + widget.document['value'].toString(),
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
                                "title": widget.document['title'],
                                "description": widget.document['description'],
                                "exchangeWith": widget.document['exchangeWith'],
                                "category": widget.document['category'],
                                "condition": widget.document['condition'],
                                "image": widget.document['image'],
                                "value": widget.document['value'],
                                "publishedAt": DateTime.now(),
                                "isPublished": true,
                                "isPromoted": false,
                                "userId": uid,
                              });
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Added!'),
                              ));
                            }
                          },
                        ),
                        // if (_isCurrentUser)
                        //   ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColor.darkOrange,
                        //       side: BorderSide.none,
                        //       shape: const StadiumBorder(),
                        //       padding: const EdgeInsets.all(10),
                        //     ),
                        //     child: const Text("Promote Ad"),
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => AdPromotionScreen(
                        //             image: widget.document['image'],
                        //             title: widget.document['title'],
                        //             description: widget.document['description'],
                        //             exchangeWith: widget.document['exchangeWith'],
                        //             category: widget.document['category'],
                        //             condition: widget.document['condition'],
                        //             value: widget.document['value'],
                        //             userId: widget.document['userId'],
                        //             userName: widget.document['userName'],
                        //             email: widget.document['userEmail'],
                        //             userImageURL: widget.document['userImageURL'],
                        //             adId: widget.document['adId'],
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // SizedBox(width: 20,),
                        // if (_isCurrentUser)
                        //   ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColor.darkOrange,
                        //       side: BorderSide.none,
                        //       shape: const StadiumBorder(),
                        //       padding: const EdgeInsets.all(10),
                        //     ),
                        //     child: const Text("Close Ad"),
                        //     onPressed: () async {
                        //       bool confirmClose = await showDialog(
                        //         context: context,
                        //         builder: (BuildContext context) {
                        //           return AlertDialog(
                        //             title: Text("Confirm"),
                        //             content: Text("Are you sure you want to close this ad?"),
                        //             actions: [
                        //               ElevatedButton(
                        //                 style: ElevatedButton.styleFrom(
                        //                   backgroundColor: AppColor.darkOrange,
                        //                 ),
                        //                 child: Text("Yes"),
                        //                 onPressed: () {
                        //                   Navigator.of(context).pop(true);
                        //                 },
                        //               ),
                        //               ElevatedButton(
                        //                 style: ElevatedButton.styleFrom(
                        //                   backgroundColor: AppColor.darkOrange,
                        //                 ),
                        //                 child: Text("No"),
                        //                 onPressed: () {
                        //                   Navigator.of(context).pop(false);
                        //                 },
                        //               ),
                        //             ],
                        //           );
                        //         },
                        //       );
                        //       // if (confirmClose) {
                        //       //   await FirebaseFirestore.instance.collection('ads')
                        //       //       .doc(widget.document['adId'])
                        //       //       .delete();
                        //       //
                        //       //   // Create a new ad in the _closeAds collection
                        //       //   await _closeAds.add({
                        //       //     "title": widget.title,
                        //       //     "description": widget.description,
                        //       //     "exchangeWith": widget.exchangeWith,
                        //       //     "category": widget.category,
                        //       //     "condition": widget.condition,
                        //       //     "image": widget.image,
                        //       //     "value": widget.value,
                        //       //     "publishedAt": DateTime.now(),
                        //       //     "isPublished": false,
                        //       //     "isPromoted": false,
                        //       //     "userId": widget.userId,
                        //       //     "email": widget.userEmail,
                        //       //     "userName": widget.userName,
                        //       //   });
                        //       //
                        //       //   Navigator.of(context).pop(); // Close the current ad detail screen
                        //       //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        //       //     content: Text('Ad closed successfully'),
                        //       //   ));
                        //       // }
                        //     },
                        //   ),


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
                        // ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColor.darkOrange,
                        //       side: BorderSide.none,
                        //       shape: const StadiumBorder(),
                        //       padding: const EdgeInsets.all(10),
                        //     ),
                        //     child: const Text("Send Offer"),
                        //     onPressed: () {},
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
                              userId: widget.document['userId'],
                              userImageURL: widget.document['userImageURL'],
                              userName: widget.document['userName'],
                              userEmail: widget.document['email'],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              widget.document['userImageURL'],
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
                                  widget.document['userName'],
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.document['email'],
                                        style: Theme.of(context).textTheme.headline4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text:widget.document['email'],));
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