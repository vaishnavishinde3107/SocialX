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
import 'package:socialx/models/message.dart';
import 'package:socialx/models/user.dart';
class DatabaseService{
  // get the instance of fireStore db & auth
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
    await _db.collection("users").doc(uid).set(userMap);
  
  }

  //Get user info
  Future<Userprofile?> getUserFromFirebase (String uid) async{
    try{

      //retrieve user doc from firebase
      DocumentSnapshot userDoc = await _db.collection("users").doc(uid).get();

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

/*
MESSAGING FEATURE
* */

  // Stream<List<Map<String, dynamic>>> getUserStream(){
  //   return _db.collection('users').snapshots().map((snapshot){
  //     return snapshot.docs.map((doc){
  //       //got through each individual user
  //       final user = doc.data();
  //
  //       //return user
  //       return {
  //         ...user,
  //         "uid": doc.id,
  //       };
  //     }).toList();
  //   });
  // }

  //send message

  Stream<List<Map<String, dynamic>>> getUserStream() {
    try {
      return FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          print("DEBUG: No users found in Firestore.");
        } else {
          print("DEBUG: Found ${snapshot.docs.length} users.");
        }

        return snapshot.docs.map((doc) {
          final user = doc.data();

          // Ensure 'email' exists to avoid null errors
          if (!user.containsKey('email')) {
            print("WARNING: Missing 'email' field in document ${doc.id}");
          }

          return {
            ...user,
            "uid": doc.id, // Ensure UID is included
          };
        }).toList();
      });
    } catch (e) {
      print("ERROR: Failed to fetch users - $e");
      return Stream.value([]); // Return an empty stream in case of failure
    }
  }


  Future<void> sendMessage(String receiverID, message) async{
    //get current user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
        senderID: currentUserId,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);

    //construct chat room ID for the twe users(sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverID];
    ids.sort(); //sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    //add new message to database
    await _db.collection("chat_rooms")
    .doc(chatRoomID)
    .collection("messages")
    .add(newMessage.toMap());
  }
  //get messages
Stream<QuerySnapshot> getMessages(String userID, otherUserID){
    FirebaseFirestore.instance.clearPersistence();
    //construct a chatroom ID for the two users
  List<String> ids = [userID, otherUserID];
  ids.sort();
  String chatRoomID = ids.join('_');

  return _db.collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .orderBy("timestamp", descending: false).snapshots();
}
}

