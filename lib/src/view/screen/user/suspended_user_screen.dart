import 'package:flutter/material.dart';

class SuspendedUserScreen extends StatefulWidget {
  const SuspendedUserScreen({super.key});

  @override
  _SuspendedUserScreenState createState() => _SuspendedUserScreenState();
}

class _SuspendedUserScreenState extends State<SuspendedUserScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Text(
          "Due to your illegale activities, you are permanentaly ban from the XchangeNET",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.deepOrange,
      automaticallyImplyLeading: false,
      title: Text("Suspended User",
        style: TextStyle(fontSize: 20,),
      ),
    );
  }
}
