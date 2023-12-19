import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xchange_net/src/controller/ad_controller.dart';
import 'package:xchange_net/src/view/screen/user/recommended_products_screen.dart';
import 'package:xchange_net/src/view/widget/ad_grid_view.dart';
import '../../widget/sign_in.dart';
import 'search_home_screen.dart';
import 'user_notification_screen.dart';

enum AppbarActionType { leading, trailing }

final AdController controller = Get.put(AdController());
final SignIn signIn = Get.put(SignIn());

class AllProductScreen extends StatefulWidget {
  const AllProductScreen({Key? key}) : super(key: key);

  @override
  State<AllProductScreen> createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  String searchText = '';
  String name = '';
  int notificationCount = 0; // Counter variable for notifications

  @override
  void initState() {
    super.initState();
    inputData();
    fetchNotificationCount();
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
  }

  final CollectionReference _adminActions =
  FirebaseFirestore.instance.collection('userNotifications').doc("$uid").collection('notification');

  // Method to fetch the notification count
  void fetchNotificationCount() async {
    // Fetch the documents from the collection
    QuerySnapshot querySnapshot = await _adminActions.where('isRead', isEqualTo: false).get();

    // Get the number of documents and update the notificationCount variable
    setState(() {
      notificationCount = querySnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "All Products",
          style: TextStyle(fontSize: 15),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white,),
            onPressed: (){
              // showSearch(context: context, delegate: CustomSearchScreen(),);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchHomeScreen()),
              );
            },
          )
        ],
        backgroundColor: Colors.deepOrange,
        leading: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_on_sharp),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserNotificationScreen()),
              ),
            ),
            if (notificationCount > 0) // Display the notification count badge if there are unread notifications
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
      // child: Align(
      //   alignment: Alignment.centerRight,
            child:
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecommendedProductsScreen(), // Create an instance of RecommendedProductsScreen
                  ),
                );
              },
              child: Text.rich(
                TextSpan(
                  text: "Recommended Products for you",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          // ),
          Expanded(
            child: Container(
              child: Center(
                child: Builder(
                  builder: (context) {
                    return ItemGrid();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}