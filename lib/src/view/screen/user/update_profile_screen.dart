import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xchange_net/core/app_color.dart';

import '../../widget/sign_in.dart';

final SignIn signIn = Get.put(SignIn());
class UpdateProfileScreen extends StatefulWidget{
  const UpdateProfileScreen({Key? key}): super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String? myimageurl;
  void initState() {
    getImageFromSharedPreferences().then((value) {
      setState(() {
        myimageurl = value;
      });
    });
  }
  Future<String?> getImageFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    String? myimageurl = keys.contains('userImageUrl') ? prefs.getString('userImageUrl') : '';
    return myimageurl;
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        automaticallyImplyLeading: true,
        title: Text(
          "Update Profile",
          style: TextStyle(fontSize: 20,),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Stack(
                children: [
              const SizedBox(height: 80),
              SizedBox(
                //     width: 180,
                //     height: 180,
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(100),
                //       child:
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child:   Image.network(myimageurl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                ),
                // height: 190,

                //   const Image(
                //     image: AssetImage('assets/images/profile_pic.png'),
                //   ),
                // )
              ),
                ],
              ),
              const SizedBox(height: 50),
              Form(child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(label: Text("Phone Number"), prefixIcon: Icon(Icons.phone)
                    ),
                  ),
                  const SizedBox(height: 70),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const UpdateProfileScreen()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkOrange, side: BorderSide.none, shape: const StadiumBorder()),
                      child: const Text("Update", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}