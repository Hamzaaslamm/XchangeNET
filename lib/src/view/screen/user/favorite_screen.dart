import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../core/app_color.dart';
import '../../widget/sign_in.dart';

final SignIn signIn = Get.put(SignIn());

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FavoriteScreenHomePage(),
    );
  }
}

class FavoriteScreenHomePage extends StatefulWidget {
  const FavoriteScreenHomePage({Key? key}) : super(key: key);

  @override
  _FavoriteScreenHomePageState createState() => _FavoriteScreenHomePageState();
}

class _FavoriteScreenHomePageState extends State<FavoriteScreenHomePage> {
  @override
  void initState() {
    // TODO: implement initState
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
    // here you write the codes to input the data into firestore
  }

  final CollectionReference _userAds = FirebaseFirestore.instance
      .collection('users')
      .doc("$uid")
      .collection('favoriteAds');

  //Delete Operation
  Future<void> _delete(String productId) async {
    await _userAds.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad removed Successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            "Favorites List",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      //Read Operation
      body: StreamBuilder<QuerySnapshot>(
        stream: _userAds.snapshots(),
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
                      //To View Ad in Detail
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
                                    Text("Description: "+
                                      documentSnapshot['description'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                    ),
                                    Text("Exchange With: "+
                                      documentSnapshot['exchangeWith'],
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text("Category: "+
                                      documentSnapshot['category'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text("Condition: "+
                                      documentSnapshot['condition'],
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text("Value: "+
                                      documentSnapshot['value'].toString(),
                                      style: TextStyle(fontSize: 15),
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_forever,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirm'),
                                                  content: Text(
                                                      'Are you sure you want to remove this ad?'),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                        AppColor.darkOrange,
                                                      ),
                                                      child: Text('Yes'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _delete(documentSnapshot
                                                            .id);
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                        AppColor.darkOrange,
                                                      ),
                                                      child: Text('No'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
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
