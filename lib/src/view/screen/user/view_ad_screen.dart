import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/app_color.dart';

class ViewAdScreen extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final String exchangeWith;
  final String category;
  final String condition;
  final int value;
  final bool isPublished;
  final String userName;
  final String email;
  final String userImageURL;

  ViewAdScreen({
    required this.image,
    required this.title,
    required this.description,
    required this.exchangeWith,
    required this.category,
    required this.condition,
    required this.value,
    required this.isPublished,
    required this.userName,
    required this.email,
    required this.userImageURL,
  });

  @override
  State<ViewAdScreen> createState() => _ViewAdScreenState();
}
class _ViewAdScreenState extends State<ViewAdScreen> {
  @override
  void initState() {
    // TODO: implement initState
    inputData();
    print(uid);
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
    print("the id is: $uid");
    // here you write the codes to input the data into firestore
  }

  final CollectionReference _ads =
  FirebaseFirestore.instance.collection('ads');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            "View Ad",
            style: TextStyle(fontSize: 20,),
          ),
        ),
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
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "Title: "+widget.title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 5),
                  Flexible(
                    child: Text(
                      "Description: "+widget.description,
                      style: TextStyle(
                        fontSize: 15,),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "Exchange With: "+widget.exchangeWith,
                      style: TextStyle(
                        fontSize: 15,),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "Category: "+widget.category,
                      style: TextStyle(
                        fontSize: 15,),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "Value: " + widget.value.toString(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visibility(
                //   visible: !widget.isPublished,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColor.darkOrange,
                //       side: BorderSide.none,
                //       shape: const StadiumBorder(),
                //       padding: const EdgeInsets.all(15),
                //     ),
                //     child: const Text("Publish Ad"),
                //     onPressed: () async {
                //       bool confirmPublish = await showDialog(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return AlertDialog(
                //             title: Text("Confirm"),
                //             content: Text("Are you sure you want to publish this ad?"),
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
                //       if (confirmPublish) {
                //         await _ads.add({
                //           "title": widget.title,
                //           "description": widget.description,
                //           "category": widget.category,
                //           "condition": widget.condition,
                //           "image": widget.image,
                //           "value": widget.value,
                //           "publishedAt": DateTime.now(),
                //           "isPublished": true,
                //           "isPromoted": false,
                //           "userId": uid,
                //         });
                //         Navigator.of(context).pop();
                //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //             content: Text('Ad published')));
                //       }
                //     },
                //   ),
                // ),

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkOrange,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Text("Publish Ad"),
                    onPressed: () async {
                      bool confirmPublish = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm"),
                            content: Text("Are you sure you want to publish this ad?"),
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
                      if (confirmPublish) {
                        await _ads.add({
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
                          "userId": uid,
                          "userName": widget.userName,
                          "email": widget.email,
                          "userImageURL": widget.userImageURL,
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Ad published')));
                      }
                    }
                ),

                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: AppColor.darkOrange,
                //     side: BorderSide.none,
                //     shape: const StadiumBorder(),
                //     padding: const EdgeInsets.all(15),
                //   ),
                //   child: const Text("Unpublish Ad"),
                //   onPressed: () async {
                //     bool confirmUnpublish = await showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return AlertDialog(
                //           title: Text("Confirm"),
                //           content: Text("Are you sure you want to unpublish this ad?"),
                //           actions: [
                //             ElevatedButton(
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: AppColor.darkOrange,
                //               ),
                //               child: Text("Yes"),
                //               onPressed: () {
                //                 Navigator.of(context).pop(true);
                //               },
                //             ),
                //             ElevatedButton(
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: AppColor.darkOrange,
                //               ),
                //               child: Text("No"),
                //               onPressed: () {
                //                 Navigator.of(context).pop(false);
                //               },
                //             ),
                //           ],
                //         );
                //       },
                //     );
                //     if (confirmUnpublish) {
                //       // => _unpublish(documentSnapshot.id),
                //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //           content: Text('Ad unpublished')));
                //     }
                //   },
                //
                //   //                 child: const Text("Unpublish Ad"),
                //   //                 onPressed: () {}
                //   // // => _unpublish(documentSnapshot.id),
                // ),
                // Visibility(
                // visible: widget.isPublished,
                //   child: ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: AppColor.darkOrange,
                //     side: BorderSide.none,
                //     shape: const StadiumBorder(),
                //     padding: const EdgeInsets.all(15),
                //   ),
                //   child: const Text("Unpublish Ad"),
                //   onPressed: () async {
                //     bool confirmUnpublish = await showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return AlertDialog(
                //           title: Text("Confirm"),
                //           content: Text("Are you sure you want to unpublish this ad?"),
                //           actions: [
                //             ElevatedButton(
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: AppColor.darkOrange,
                //               ),
                //               child: Text("Yes"),
                //               onPressed: () {
                //                 Navigator.of(context).pop(true);
                //               },
                //             ),
                //             ElevatedButton(
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: AppColor.darkOrange,
                //               ),
                //               child: Text("No"),
                //               onPressed: () {
                //                 Navigator.of(context).pop(false);
                //               },
                //             ),
                //           ],
                //         );
                //       },
                //     );
                //     if (confirmUnpublish) {
                //       // => _unpublish(documentSnapshot.id),
                //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //           content: Text('Ad unpublished')));
                //     }
                //   },
                //
                //   //                 child: const Text("Unpublish Ad"),
                //   //                 onPressed: () {}
                //   // // => _unpublish(documentSnapshot.id),
                // ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}