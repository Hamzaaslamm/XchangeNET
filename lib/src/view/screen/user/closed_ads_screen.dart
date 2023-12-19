import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xchange_net/src/view/screen/user/view_ad_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/app_color.dart';
import '../../widget/sign_in.dart';
import 'closed_ads_screen.dart';

final SignIn signIn = Get.put(SignIn());
class ClosedAdsScreen extends StatefulWidget {
  const ClosedAdsScreen({super.key});

  @override
  _ClosedAdsScreenState createState() => _ClosedAdsScreenState();
}

class _ClosedAdsScreenState extends State<ClosedAdsScreen> {

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
    String? email = keys.contains('userEmail') ? prefs.getString('userEmail') : '';
    return email;
  }

  Future<String?> getImageFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? myimageurl = keys.contains('userImageUrl') ? prefs.getString('userImageUrl') : '';
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
    print("the id is: $uid");
    // here you write the codes to input the data into firestore
  }

  final CollectionReference _closeAds = FirebaseFirestore.instance
      .collection('users')
      .doc("$uid")
      .collection('closeAds');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        automaticallyImplyLeading: true,
        title: Text(
          "Closed Ads",
          style: TextStyle(fontSize: 20,),
        ),
        centerTitle: true,
      ),
      //Read Operation
      body: StreamBuilder<QuerySnapshot>(
        stream: _closeAds.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final data = streamSnapshot.data!;
            if (data.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = data.docs[index];
                  return ElevatedButton(
                    onPressed: () {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      documentSnapshot['title'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text("Description: " +
                                        documentSnapshot['description'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                    ),
                                    Text("Exchange With: " +
                                        documentSnapshot['exchangeWith'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                    ),
                                    Text("Category: " +
                                        documentSnapshot['category'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text("Condition: " +
                                        documentSnapshot['condition'],
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text("Value: " +
                                        documentSnapshot['value'].toString(),
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
                  "No Ads Found!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAppBar(),
//       body: Center(
//         child: Text(
//           "No Ad Found!",
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
//   AppBar buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.deepOrange,
//       automaticallyImplyLeading: true,
//       title: Text(
//         "Closed Ads",
//         style: TextStyle(fontSize: 20,),
//       ),
//       centerTitle: true,
//     );
//   }
// }
