import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/sign_in.dart';
import 'ad_detail_screen.dart';

final SignIn signIn = Get.put(SignIn());

class RecommendedProductsScreen extends StatefulWidget {
  const RecommendedProductsScreen({Key? key}) : super(key: key);

  @override
  State<RecommendedProductsScreen> createState() =>
      _RecommendedProductsScreenState();
}

class _RecommendedProductsScreenState extends State<RecommendedProductsScreen> {
  String? name;
  String? email;
  String? myimageurl;

  @override
  void initState() {
    super.initState();
    inputData();
    getNameFromSharedPreferences().then((value) {
      setState(() {
        name = value;
      });
    });
    getEmailFromSharedPreferences().then((value) {
      setState(() {
        email = value;
      });
    });
    getImageFromSharedPreferences().then((value) {
      setState(() {
        myimageurl = value;
      });
    });
  }

  Future<String?> getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? name = keys.contains('userName') ? prefs.getString('userName') : '';
    return name;
  }

  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? email =
    keys.contains('userEmail') ? prefs.getString('userEmail') : '';
    return email;
  }

  Future<String?> getImageFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? myimageurl =
    keys.contains('userImageUrl') ? prefs.getString('userImageUrl') : '';
    return myimageurl;
  }

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

  final CollectionReference _ads =
  FirebaseFirestore.instance.collection('ads');

  final CollectionReference _userAds =
  FirebaseFirestore.instance.collection('users').doc('$uid').collection('ads');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        automaticallyImplyLeading: true,
        title: Text(
          "Recommended Products",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _userAds.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> userAdsSnapshot) {
              if (userAdsSnapshot.hasData) {
                final userAdsData = userAdsSnapshot.data!;
                // if (userAdsData.docs.isNotEmpty) {
                //   // Display all values of the 'exchangeWith' attribute in the console
                //   for (final documentSnapshot in userAdsData.docs) {
                //     final exchangeWithValue = documentSnapshot['exchangeWith'];
                //     print('ExchangeWith from _userAds: $exchangeWithValue');
                //   }
                // }
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
          child: StreamBuilder<QuerySnapshot>(
          stream: _userAds.snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> userAdsSnapshot) {
    if (userAdsSnapshot.hasData) {
    final userAdsData = userAdsSnapshot.data!;
    if (userAdsData.docs.isNotEmpty) {
    final userExchangeWithList = userAdsData.docs
        .map((doc) => doc['exchangeWith'] as String)
        .toList();
    return StreamBuilder<QuerySnapshot>(
      stream: _ads.where('title', whereIn: userExchangeWithList).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> adsSnapshot) {
        if (adsSnapshot.hasData) {
          final adsData = adsSnapshot.data!;
          if (adsData.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: adsData.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                adsData.docs[index];
                String adId = documentSnapshot.id;
                final adUserId = documentSnapshot['userId'];
                if (adUserId == uid) {
                  return const SizedBox.shrink();
                }
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return AdDetailScreen(
                            image: documentSnapshot['image'],
                            title: documentSnapshot['title'],
                            description: documentSnapshot['description'],
                            exchangeWith: documentSnapshot['exchangeWith'],
                            category: documentSnapshot['category'],
                            condition: documentSnapshot['condition'],
                            value: documentSnapshot['value'].toString(),
                            userId: documentSnapshot['userId'],
                            userName: documentSnapshot['userName'],
                            userEmail: documentSnapshot['email'],
                            userImageURL: documentSnapshot['userImageURL'],
                            adId: adId,
                          );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 0,
                      ),
                      child: Card(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Image.network(
                                    documentSnapshot['image'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        documentSnapshot['title'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "Description: " +
                                            documentSnapshot['description'],
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                      ),
                                      Text(
                                        "Exchange With: " +
                                            documentSnapshot['exchangeWith'],
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                      ),
                                      Text(
                                        "Category: " +
                                            documentSnapshot['category'],
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        "Condition: " +
                                            documentSnapshot['condition'],
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        "Value: " +
                                            documentSnapshot['value']
                                                .toString(),
                                        style: TextStyle(fontSize: 15),
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                "No ads matching your choices found.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        },
    );
    }
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
    },
          ),
          ),
        ],
      ),
    );
  }
}