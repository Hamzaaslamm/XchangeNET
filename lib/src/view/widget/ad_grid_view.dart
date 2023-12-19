import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/user/ad_detail_screen.dart';

class Ads {
  String title;
  String description;
  String exchangeWith;
  String category;
  String condition;
  String image;
  String value;
  DateTime date;
  String userId;
  String userName;
  String email;
  String userImageURL;
  bool isPromoted;

  Ads({
    required this.title,
    required this.description,
    required this.exchangeWith,
    required this.category,
    required this.condition,
    required this.image,
    required this.value,
    required this.date,
    required this.userId,
    required this.userImageURL,
    required this.email,
    required this.userName,
    this.isPromoted = false, // Default value for isPromoted
  });
}

class ItemGrid extends StatefulWidget {
  @override
  State<ItemGrid> createState() => _ItemGridState();
}

class _ItemGridState extends State<ItemGrid> {
  // String? uid;
  static String? uid;


  @override
  void initState() {
    super.initState();
    inputData();
    fetchBlockedUsers();
    fetchSuspendUsers();
  }

  void inputData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    setState(() {
      uid = user?.uid;
    });
  }

  //Blocked User List
  final CollectionReference _blockedUsers =
  FirebaseFirestore.instance.collection('admin')
      .doc("nIZhmR2ZV9dOCBcGwL4cPwWGsXs1")
      .collection('blockUsers');

  //Suspended User List
  final CollectionReference _suspendUsers =
  FirebaseFirestore.instance.collection('admin')
      .doc("nIZhmR2ZV9dOCBcGwL4cPwWGsXs1")
      .collection('suspendUsers');


  Future<void> fetchBlockedUsers() async {
    try {
      QuerySnapshot blockedUsersSnapshot = await _blockedUsers.get();
      List<DocumentSnapshot> blockedUsers = blockedUsersSnapshot.docs;
      for (var userSnapshot in blockedUsers) {
      String? reportedId;
        reportedId = userSnapshot['reportedId'];
      deleteAdsOfBlockedUsers(reportedId!);
      }
    } catch (error) {
      print("Error fetching blocked users: $error");
    }
  }

  Future<void> deleteAdsOfBlockedUsers(String reportedId) async {
    try {
      final CollectionReference adsCollection = FirebaseFirestore.instance.collection('ads');
      QuerySnapshot adsSnapshot = await adsCollection.where('userId', isEqualTo: reportedId).get();

      for (QueryDocumentSnapshot adSnapshot in adsSnapshot.docs) {
        String adId = adSnapshot.id;
        await adsCollection.doc(adId).delete();
      }
    } catch (error) {
      print('Failed to delete ads: $error');
    }
  }


  Future<void> fetchSuspendUsers() async {
    try {
      QuerySnapshot suspendUsersSnapshot = await _suspendUsers.get();
      List<DocumentSnapshot> suspendUsers = suspendUsersSnapshot.docs;
      for (var userSnapshot in suspendUsers) {
        String? reportedId;
        reportedId = userSnapshot['reportedId'];
        deleteAdsOfSuspendedUsers(reportedId!);
      }
    } catch (error) {
      print("Error fetching blocked users: $error");
    }
  }

  Future<void> deleteAdsOfSuspendedUsers(String reportedId) async {
    try {
      final CollectionReference adsCollection = FirebaseFirestore.instance.collection('ads');
      QuerySnapshot adsSnapshot = await adsCollection.where('userId', isEqualTo: reportedId).get();

      for (QueryDocumentSnapshot adSnapshot in adsSnapshot.docs) {
        String adId = adSnapshot.id;
        await adsCollection.doc(adId).delete();
      }
    } catch (error) {
      print('Failed to delete ads: $error');
    }
  }


  Future<void> deleteAd(String adId) async {
    try {
      final CollectionReference adsCollection = FirebaseFirestore.instance.collection('ads');
      await adsCollection.doc(adId).delete();
      print('Ad unpublished successfully');
    } catch (error) {
      print('Failed to delete ad: $error');
    }
  }

  Future<void> _unpublishAd(String adId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to unpublish this ad?'),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                deleteAd(adId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _closeAd(String adId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to close this ad?'),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // deleteAd(adId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    CollectionReference _ads = FirebaseFirestore.instance.collection('ads');
    return StreamBuilder<QuerySnapshot>(
      stream: _ads
          .where('isPublished', isEqualTo: true)
          .orderBy('publishedAt', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasError) {
          return Text('Error: ${streamSnapshot.error}');
        }

        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        List<Ads> ads = streamSnapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Ads(
            title: data['title'],
            description: data['description'],
            exchangeWith: data['exchangeWith'],
            category: data['category'],
            condition: data['condition'],
            image: data['image'],
            value: data['value'].toString(),
            date: (data['publishedAt'] as Timestamp).toDate(),
            userId: data['userId'].toString(),
            userName: data['userName'],
            email: data['email'],
            userImageURL: data['userImageURL'],
            isPromoted: data['isPromoted'] ?? false,
          );
        }).toList();

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisExtent: 300,
            mainAxisSpacing: 10,
          ),
          itemCount: ads.length,
          itemBuilder: (BuildContext context, int index) {
            bool showIconButton = ads[index].userId == uid;
            String adId = streamSnapshot.data!.docs[index].id;

            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return AdDetailScreen(
                    image: ads[index].image,
                    title: ads[index].title,
                    description: ads[index].description,
                    exchangeWith: ads[index].exchangeWith,
                    category: ads[index].category,
                    condition: ads[index].condition,
                    value: ads[index].value,
                    userId: ads[index].userId,
                    userName: ads[index].userName,
                    userEmail: ads[index].email,
                    userImageURL: ads[index].userImageURL,
                    adId: adId,
                  );
                }));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Image.network(
                        ads[index].image,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                ads[index].title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(height: 5),
                            Flexible(
                              child: Text(
                                "Description: " + ads[index].description,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 1),
                            Flexible(
                              child: Text(
                                "Exchange With: " + ads[index].exchangeWith,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 1),
                            Flexible(
                              child: Text(
                                "Category: " + ads[index].category,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 1),
                            Flexible(
                              child: Text(
                                "Value: " + ads[index].value,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Flexible(
                              child: Text(
                                DateFormat.MMMMEEEEd().format(ads[index].date).toString(),
                                style: TextStyle(
                                  fontSize: 9,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (showIconButton)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _unpublishAd(adId);
                                        },
                                        icon: Icon(Icons.unpublished, color: Colors.red),
                                      ),
                                      // SizedBox(width: 1),
                                      // IconButton(
                                      //   onPressed: () {
                                      //     _closeAd(adId);
                                      //   },
                                      //   icon: Icon(Icons.done_outline, color: Colors.green),
                                      // ),
                                    ],
                                  ),
                                Spacer(), // This will push the promoted button to the right
                                if (ads[index].isPromoted)
                                IconButton(
                                  onPressed: () {
                                    // Handle promoted action
                                  },
                                  icon: Icon(Icons.verified, color: Colors.green),
                                ),
                              ],
                            ),
                      // Row(
                              //   children: [
                              //     if (showIconButton)
                              //     IconButton(
                              //       onPressed: () {
                              //         _unpublishAd(adId);
                              //       },
                              //       icon: Icon(Icons.unpublished, color: Colors.red,),
                              //     ),
                              //
                              //
                              //     // SizedBox(height: 2,),
                              //     // if (ads[index].isPromoted)
                              //       IconButton(
                              //         onPressed: () {
                              //           // Handle promoted action
                              //         },
                              //         icon: Icon(Icons.verified, color: Colors.green,),
                              //       ),
                              //
                              //     if (showIconButton)
                              //       SizedBox(width: 40,),
                              //     if (showIconButton)
                              //       IconButton(
                              //         onPressed: () {
                              //           _closeAd(adId);
                              //         },
                              //         icon: Icon(Icons.done_outline, color: Colors.green,),
                              //       ),
                              //
                              //   ],
                              // ),
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
      },
    );
  }
}