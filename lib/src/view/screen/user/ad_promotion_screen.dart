import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/app_color.dart';

class AdPromotionScreen extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final String exchangeWith;
  final String category;
  final String condition;
  final String value;
  final String userId;
  final String userName;
  final String email;
  final String userImageURL;
  final String adId;

  AdPromotionScreen({
    required this.image,
    required this.title,
    required this.description,
    required this.exchangeWith,
    required this.category,
    required this.condition,
    required this.value,
    required this.userId,
    required this.userName,
    required this.email,
    required this.userImageURL,
    required this.adId,
  });

  @override
  _AdPromotionScreenState createState() => _AdPromotionScreenState();
}

class _AdPromotionScreenState extends State<AdPromotionScreen> {
  // text fields' controllers
  final TextEditingController _durationController = TextEditingController();

  bool _isTextBlink = true;
  String? _selectedDuration;
  String? usersId;
  static String? uid;

  String? get getId {
    return uid;
  }

  List<String> _durationOptions = [
    '1 Day (Rs.50)',
    '3 Day (Rs.100)',
    '7 Days (Rs.300)',
    '15 Days (Rs.500)',
    '30 Days (Rs.1000)'
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _isTextBlink = !_isTextBlink;
      });
    });
    inputData();
  }

  void inputData() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
  }

  final CollectionReference _promotionAds = FirebaseFirestore.instance
      .collection('promotion');
  final CollectionReference _ads = FirebaseFirestore.instance
      .collection('ads');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            "Ad Promotion",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      //Read Operation
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/Promotion.jpg',
              ),
              SizedBox(height: 25,),
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDuration = newValue;
                    _durationController.text =
                        newValue ?? ''; // Update text in controller
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Duration',
                ),
                items: _durationOptions.map((option) {
                  return DropdownMenuItem(
                    child: Text(option),
                    value: option,
                  );
                }).toList(),
              ),
              SizedBox(height: 25,),
              Text(
                'Select the ad promotion duration of your choice.'
                    ' After the selection, send the amount to this number via JazzCash/EsayPaisa. Aslo send screenshot of transaction via Whatsapp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15,),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isTextBlink ? Colors.red : Colors.blue,
                ),
                child: Text('0312-1234567'),
              ),
            ],
          ),
        ),
      ),
      // Position the button at the bottom of the screen
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.darkOrange,
          side: BorderSide.none,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.all(15),
        ),
        child: const Text('Promote'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Confirm"),
              content: Text("Are you sure you want to promote this ad?"),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.darkOrange,
                  ),
                  onPressed: () async {
                    final String duration = _durationController.text;
                    if (duration.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('This field is required.'),
                        ),
                      );
                      return;
                    } else {
                      await _promotionAds.add({
                        "title": widget.title,
                        "description": widget.description,
                        "category": widget.category,
                        "condition": widget.condition,
                        "username": widget.userName,
                        "email": widget.email,
                        "image": widget.image,
                        "exchangeWith": widget.exchangeWith,
                        "value": widget.value,
                        "duration": duration,
                        "createdAt": DateTime.now(),
                        "isPublished": true,
                        "isPromoted": false,
                        "userId": uid,
                        "userImageURL": widget.userImageURL,
                      });
                      _durationController.text = '';
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Your request sent to admin successfully')),
                      );
                      await _ads.doc(widget.adId).delete();
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Yes"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.darkOrange,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("No"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
