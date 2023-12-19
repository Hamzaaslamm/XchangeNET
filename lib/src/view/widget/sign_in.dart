import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignIn {


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String? name;
  String? email;
  String? imageUrl;

  Future<String?> signInWithGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Firebase.initializeApp();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn
        .signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication =
    await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication?.accessToken,
      idToken: googleSignInAuthentication?.idToken,
    );

    final UserCredential authResult =
    await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      await prefs.setBool('isLoggedIn', true);
      //duplicate
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      // if (isLoggedIn) {
      //   name = prefs.getString('userName');
      //   email = prefs.getString('userEmail');
      //   imageUrl = prefs.getString('userImageUrl');
      //
      //   // Return the stored user instance
      //   return '$name $email $imageUrl';
      // }
      //duplicate ends
      // Store user instance in shared preferences
      await prefs.setString('userName', user.displayName!);
      await prefs.setString('userEmail', user.email!);
      await prefs.setString('userImageUrl', user.photoURL!);
      print("This is my user");
      print(user);
      // Checking if email and name is null
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);

      name = user.displayName!;
      email = user.email!;
      imageUrl = user.photoURL!;

      if (name!.contains(" ")) {
        name = name?.substring(0, name?.indexOf(" "));
      }
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User? currentUser = _auth.currentUser;
      assert(user.uid == currentUser?.uid);

      print('signInWithGoogle succeeded: $user');

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = {
        'email': user.email,
        'image': user.photoURL,
        'name': user.displayName,
        'status': "Offline",
        'uid': user.uid,
      };
      await userRef.set(userData, SetOptions(merge: true));
      return '$user';
    }
    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    print("User Signed Out");
  }
}