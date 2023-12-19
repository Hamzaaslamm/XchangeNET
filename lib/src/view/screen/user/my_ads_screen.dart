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
class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({Key? key}) : super(key: key);

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAdsHomePage(),
    );
  }
}

class MyAdsHomePage extends StatefulWidget {
  const MyAdsHomePage({Key? key}) : super(key: key);

  @override
  _MyAdsHomePageState createState() => _MyAdsHomePageState();
}

class _MyAdsHomePageState extends State<MyAdsHomePage> {
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


  // text fields' controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _exchangeWithController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String imageUrl = '';
  File? _imageFile;

  String? _selectedCategory;
  String? _selectedCondition;
  String? usersId;
  static String? uid;

  String? get getId {
    return uid;
  }

  List<String> _categoryOptions = [
    'Mobile & Watch',
    'Computer & Laptop',
    'Vehicles & Bikes',
    'Property',
    'Electronics & Home Appliances',
    'Services & Jobs',
    'Animals',
    'Furniture & Home Decor',
    'Fashion & Beauty',
    'Study, Sports & Hobbies',
    'Kids'
  ];
  List<String> _conditionOptions = ['New', 'Used'];

  void inputData() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;
  }

  final CollectionReference _userAds = FirebaseFirestore.instance
      .collection('users')
      .doc("$uid")
      .collection('ads');

  //Create Operation
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: _exchangeWithController,
                    decoration: const InputDecoration(labelText: 'Exchange With'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                        _categoryController.text =
                            newValue ?? ''; // Update text in controller
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                    items: _categoryOptions.map((option) {
                      return DropdownMenuItem(
                        child: Text(option),
                        value: option,
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCondition = newValue;
                        _conditionController.text =
                            newValue ?? ''; // Update text in controller
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Condition',
                    ),
                    items: _conditionOptions.map((option) {
                      return DropdownMenuItem(
                        child: Text(option),
                        value: option,
                      );
                    }).toList(),
                  ),
                  IconButton(
                    onPressed: () async {
                      ImagePicker imgpic = ImagePicker();
                      XFile? file =
                          await imgpic.pickImage(source: ImageSource.gallery);
                      print('${file?.path}');
                      if (file == null) return;
                      String uniFname =
                          DateTime.now().microsecondsSinceEpoch.toString();
                      Reference refRoot = FirebaseStorage.instance.ref();
                      Reference refDir = refRoot.child('images');
                      Reference refUpload = refDir.child(uniFname);

                      try {
                        await refUpload.putFile(File(file!.path));
                        imageUrl = await refUpload.getDownloadURL();
                      } catch (error) {}

                      setState(() {
                        _imageFile = File(file!.path);
                      });
                    },
                    icon: Icon(Icons.camera_alt),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 150,
                    height: 100,
                    child: _imageFile == null
                        ? Text('No image selected.')
                        : Image.file(_imageFile!),
                  ),
                  TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkOrange,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Text('Create'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Confirm"),
                          content:
                              Text("Are you sure you want to create this ad?"),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.darkOrange,
                              ),
                              onPressed: () async {
                                final String title = _titleController.text;
                                final String description =
                                    _descriptionController.text;
                                final String exchangeWith =
                                    _exchangeWithController.text;
                                final String category =
                                    _categoryController.text;
                                final String condition =
                                    _conditionController.text;
                                final String image = imageUrl.toString();
                                final int? value =
                                    int.tryParse(_valueController.text);
                                if (title.isEmpty ||
                                    description.isEmpty ||
                                    exchangeWith.isEmpty ||
                                    category.isEmpty ||
                                    condition.isEmpty ||
                                    image.isEmpty ||
                                    value == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('All fields are required.'),
                                    ),
                                  );
                                  return;
                                } else {
                                  await _userAds.add({
                                    "title": title,
                                    "description": description,
                                    "exchangeWith": exchangeWith,
                                    "category": category,
                                    "condition": condition,
                                    "image": image,
                                    "value": value,
                                    "createdAt": DateTime.now(),
                                    "isPublished": false,
                                    "isPromoted": false,
                                    "userId": uid,
                                    "userName": name,
                                    "email": email,
                                    "userImageURL": myimageurl,
                                  });
                                  _titleController.text = '';
                                  _descriptionController.text = '';
                                  _exchangeWithController.text = '';
                                  _categoryController.text = '';
                                  _conditionController.text = '';
                                  _imageController.text = '';
                                  _valueController.text = '';
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'You have successfully created ad')));
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
                  )
                ],
              ),
            ),
          );
        });
  }

  //Update Operation
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _titleController.text = documentSnapshot['title'];
      _descriptionController.text = documentSnapshot['description'];
      _categoryController.text = documentSnapshot['category'];
      _conditionController.text = documentSnapshot['condition'];
      _imageController.text = documentSnapshot['image'];
      _valueController.text = documentSnapshot['value'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                        _categoryController.text =
                            newValue ?? ''; // Update text in controller
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                    items: _categoryOptions.map((option) {
                      return DropdownMenuItem(
                        child: Text(option),
                        value: option,
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCondition = newValue;
                        _conditionController.text =
                            newValue ?? ''; // Update text in controller
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Condition',
                    ),
                    items: _conditionOptions.map((option) {
                      return DropdownMenuItem(
                        child: Text(option),
                        value: option,
                      );
                    }).toList(),
                  ),
                  IconButton(
                    onPressed: () async {
                      ImagePicker imgpic = ImagePicker();
                      XFile? file =
                          await imgpic.pickImage(source: ImageSource.gallery);
                      print('${file?.path}');
                      if (file == null) return;
                      String uniFname =
                          DateTime.now().microsecondsSinceEpoch.toString();
                      Reference refRoot = FirebaseStorage.instance.ref();
                      Reference refDir = refRoot.child('images');
                      Reference refUpload = refDir.child(uniFname);

                      try {
                        await refUpload.putFile(File(file!.path));
                        imageUrl = await refUpload.getDownloadURL();
                      } catch (error) {}

                      setState(() {
                        _imageFile = File(file!.path);
                      });
                    },
                    icon: Icon(Icons.camera_alt),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 150,
                    height: 100,
                    child: _imageFile == null
                        ? Text('No image selected.')
                        : Image.file(_imageFile!),
                  ),
                  TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.darkOrange,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text('Update'),
                      onPressed: () async {
                        final String title = _titleController.text;
                        final String description = _descriptionController.text;
                        final String category = _categoryController.text;
                        final String condition = _conditionController.text;
                        final String image = imageUrl.toString();
                        final int? value = int.tryParse(_valueController.text);
                        if (title.isEmpty ||
                            description.isEmpty ||
                            category.isEmpty ||
                            condition.isEmpty ||
                            image.isEmpty ||
                            value == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('All fields are required.'),
                            ),
                          );
                          return;
                        } else {
                          await _userAds.doc(documentSnapshot!.id).update({
                            "title": title,
                            "description": description,
                            "category": category,
                            "condition": condition,
                            "image": image,
                            "value": value
                          });
                          _titleController.text = '';
                          _descriptionController.text = '';
                          _categoryController.text = '';
                          _conditionController.text = '';
                          _imageController.text = '';
                          _valueController.text = '';
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'You have successfully updated ad')));
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  //Delete Operation
  Future<void> _delete(String productId) async {
    await _userAds.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted ad')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            "My Ads",
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ViewAdScreen(
                          image: documentSnapshot['image'],
                          title: documentSnapshot['title'],
                          description: documentSnapshot['description'],
                          exchangeWith: documentSnapshot['exchangeWith'],
                          category: documentSnapshot['category'],
                          condition: documentSnapshot['condition'],
                          value: documentSnapshot['value'],
                          isPublished: documentSnapshot['isPublished'],
                          userName: documentSnapshot['userName'],
                          email: documentSnapshot['email'],
                          userImageURL: documentSnapshot['userImageURL']
                        );
                      }));
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // IconButton(
                                        //   icon: const Icon(
                                        //     Icons.edit, color: Colors.black,
                                        //   ),
                                        //   onPressed: () => _update(documentSnapshot),
                                        // ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirm'),
                                                  content: Text(
                                                      'Are you sure you want to edit this ad?'),
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
                                                        _update(
                                                            documentSnapshot);
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
                                                      'Are you sure you want to delete this ad?'),
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
      // Add new Ad
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Adjust padding as needed
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.darkOrange,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.all(10), // Adjust padding as needed
                    textStyle: TextStyle(
                      fontSize: 16, // Adjust font size as needed
                    ),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.3, // Adjust width as needed
                      0,
                    ),
                  ),
                  child: const Text("Create Ad"),
                  onPressed: () => _create(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Adjust padding as needed
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.darkOrange,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.all(10), // Adjust padding as needed
                    textStyle: TextStyle(
                      fontSize: 16, // Adjust font size as needed
                    ),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.3, // Adjust width as needed
                      0,
                    ),
                  ),
                  child: const Text("Closed Ad"),
                  onPressed: () {
                    // Now, navigate to the ChatScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClosedAdsScreen(
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

    );
  }
}
