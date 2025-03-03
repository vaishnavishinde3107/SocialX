/*

 DATABASE SERVICE
 This class handle all the data to firebase

 -User profile
 -Post message
 -Likes
 -Comments
 -Account stuff( report / delete account / block)
 -Follow / Unfollow
 -Search users
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialx/models/user.dart';
class DatabaseService{
  // get the instance of firestore db & auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

/*
  USER PROFILE

  WHEN A NEW USER REGISTERS, WE CREATE AN ACCOUNT FOR THEM, BUT LET'S ALSO STORE
  THEIR DETAILS IN THE DATABASE TO DISPLAY ON THEIR PROFILE PAGE

 */

  // Save user info
  Future<void> saveUserInfoInFirebase({
    required String name, required String email}) async {

    //get current uid
    String uid = _auth.currentUser!.uid;

    //extract username from email
    String username = email.split('@')[0];

    //create a user profile
    Userprofile user = Userprofile(uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
    );
    
    //convert user into a map so that we can store in firebase
    final userMap = user.toMap();

    //save user info in firebase
    await _db.collection("Users").doc(uid).set(userMap);
  
  }

  //Get user info
  Future<Userprofile?> getUserFromFirebase (String uid) async{
    try{

      //retrieve user doc from firebase
      DocumentSnapshot userDoc = await _db.collection("User").doc(uid).get();

      //convert doc to user profile
      return Userprofile.fromDocument(userDoc);

    }catch (e){
      print (e);
      return null;
      }

  }

/*
  POST MESSAGE

 */

/*
  LIKES

 */

/*
  COMMENTS
 */

/*
  ACCOUNT STUFFS

 */

/*
 FOLLOW

  */
}

