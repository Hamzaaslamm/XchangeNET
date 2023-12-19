import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/app_theme_admin.dart';
import '../../widget/sign_in.dart';
import 'admin_screen.dart';


final SignIn signIn = Get.put(SignIn());

class PromotionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: _PromotionScreenContent(),
    );
  }
}

class _PromotionScreenContent extends StatefulWidget {
  @override
  _PromotionScreenContentState createState() => _PromotionScreenContentState();
}

class _PromotionScreenContentState extends State<_PromotionScreenContent>
    with SingleTickerProviderStateMixin {
  List<DocumentSnapshot>? _promotionListData; // List to store blocked users data
  bool _isPromoted = false;

  String? myname;
  String? myimageurl;


  Future<String?> getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? name = keys.contains('userName') ? prefs.getString('userName') : '';
    return name;
  }
  Future<String?> getImageFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? myimageurl = keys.contains('userImageUrl') ? prefs.getString('userImageUrl') : '';
    return myimageurl;
  }


  @override
  void initState() {
    inputData();
    super.initState();
    getNameFromSharedPreferences().then((value) {
      setState(() {
        myname = value;
      });
    });
    getImageFromSharedPreferences().then((value) {
      setState(() {
        myimageurl = value;
      });
    });
    // Fetch Promotions data and update the list
    fetchPromotionData();
  }

  // String imageUrl = '';
  // String? usersId;
  static String? uid;

  String? get getId {
    return uid;
  }

  void inputData() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
  }

//To Get Promotions Requests
  final CollectionReference _promotionRequest = FirebaseFirestore.instance.collection('promotion');
  final CollectionReference _userAds = FirebaseFirestore.instance.collection('ads');

  // Method to fetch promotion data
  void fetchPromotionData() async {
    try {
      QuerySnapshot snapshot = await _promotionRequest.get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _promotionListData = snapshot.docs;
        });
      }
    } catch (e) {
      // Handle any errors here
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

  Future<void> _markAsResolved(String documentId) async {
   try{
    await _promotionRequest.doc(documentId).update({
      'isPromoted': true,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promotion approved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
  // Handle any errors here
  print('Error unblocking user: $e');
  }
  }


  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Container(
      color: isLightMode ? AppThemeAdmin.nearlyWhite : AppThemeAdmin.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: isLightMode ? AppThemeAdmin.nearlyWhite : AppThemeAdmin.nearlyBlack,
          appBar: AppBar(
            backgroundColor: isLightMode ? Colors.white : AppThemeAdmin.dark_grey,
            title: Text(
              'Promotion',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Pending',
                    style: TextStyle(color: _isPromoted ? Colors.grey : Colors.black,),),
                ),
                Tab(
                  child: Text('Approved',
                  style: TextStyle(color: _isPromoted ? Colors.black : Colors.grey,),),
                ),
              ],
              onTap: (index) {
                setState(() {
                  _isPromoted = index == 1;
                });
              },
            ),
          ),
          body: TabBarView(
            children: [
              _buildPromotionList(isPromoted: false),
              _buildPromotionList(isPromoted: true),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the list of Promotion
  Widget _buildPromotionList({required bool isPromoted}) {
    if (_promotionListData != null && _promotionListData!.isNotEmpty) {
      List<DocumentSnapshot> filteredList = _promotionListData!.where((snapshot) => snapshot['isPromoted'] == isPromoted).toList();
      int? _selectedDuration; // Variable to store the selected duration


      if (filteredList.isNotEmpty) {
        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot documentSnapshot = filteredList[index];
            return Card(
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
                      flex: 4,
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              documentSnapshot['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Description: " + documentSnapshot['description'],
                              style: TextStyle(fontSize: 15),
                              maxLines: 4,
                            ),
                          SizedBox(height: 1),
                          Text(
                            "Exchange With: " + documentSnapshot['exchangeWith'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                          SizedBox(height: 1),
                          Text(
                            "Category: " + documentSnapshot['category'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                          SizedBox(height: 1),
                          Text(
                            "Condition: " + documentSnapshot['condition'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                          SizedBox(height: 1),
                          Text(
                            "Value: " + documentSnapshot['value'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                          SizedBox(height: 1),
                          Text(
                            "Duration: " + documentSnapshot['duration'],
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),
                            maxLines: 4,
                          ),
                          SizedBox(height: 1),
                          Text(
                            "User: " + documentSnapshot['username'],
                            style: TextStyle(fontSize: 15),
                            maxLines: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: isPromoted // Disable the button onPressed when in the Approved Tab
                                ? null
                                    : () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      int? _selectedDuration; // Variable to store the selected duration
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: Text('Duration'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DropdownButton<int>(
                                                  value: _selectedDuration,
                                                  items: [
                                                    DropdownMenuItem(
                                                      value: 1,
                                                      child: Text('1 Day'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 3,
                                                      child: Text('3 Days'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 7,
                                                      child: Text('7 Days'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 15,
                                                      child: Text('15 Days'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 30,
                                                      child: Text('30 Days'),
                                                    ),
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedDuration = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.deepOrange,
                                                ),
                                                child: Text('Approve'),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();  // Close the current screen

                                                  // Navigate to AdminScreen
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => AdminScreen(),
                                                    ),
                                                  );
                                                  // Add data to _userAds collection
                                                  await _userAds.add({
                                                    "title": documentSnapshot['title'],
                                                    "description": documentSnapshot['description'],
                                                    "exchangeWith": documentSnapshot['exchangeWith'],
                                                    "category": documentSnapshot['category'],
                                                    "condition": documentSnapshot['condition'],
                                                    "image": documentSnapshot['image'],
                                                    "value": documentSnapshot['value'],
                                                    // "publishedAt": DateTime.now().add(Duration(days: 365)),
                                                    "publishedAt": DateTime.now().add(Duration(days: _selectedDuration ?? 0)),
                                                    "isPublished": true,
                                                    "isPromoted": true,
                                                    "userId": documentSnapshot['userId'],
                                                    "userName": documentSnapshot['username'],
                                                    "email": documentSnapshot['email'],
                                                    "userImageURL": documentSnapshot['userImageURL'],
                                                  });

                                                  // Send notification to the target user
                                                  await _targetUserNotification(
                                                    documentSnapshot['userId'], // Pass the userId here
                                                    '$myname',
                                                    '$myimageurl',
                                                    'Your ad promotion request has been approved',
                                                  );

                                                  // Mark the document as resolved
                                                  await _markAsResolved(documentSnapshot.id);

                                                },
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.deepOrange,
                                                ),
                                                child: Text('No'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.verified,
                                  color: isPromoted ? Colors.green : Colors.black54, // Set the button color to green for Approved Tab
                                ),
                                label: Text(
                                  isPromoted ? 'Approved' : 'Approve', // Set the text to 'Approved' in the Approved Tab
                                  style: TextStyle(
                                    color: Colors.black, // Set the text color to black
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  primary: Colors.transparent, // Make the button background transparent
                                  padding: EdgeInsets.zero, // Remove padding around the icon and text
                                ),
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
            );
          },
        );
      } else {
        return Center(
          child: Text(
            isPromoted ? "No approved promotions found!" : "No pending promotions found!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    } else {
      return Center(
        child: Text(
          "No promotion request found!",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
