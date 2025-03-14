import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialx/models/message.dart'; // Import the Message class
import 'package:socialx/models/user.dart'; // Import the Userprofile class
import 'package:socialx/models/post.dart'; // Import the Post class

class DatabaseService {
  // Get the instance of Firestore db & auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*
    USER PROFILE
  */

  // Save user info
  Future<void> saveUserInfoInFirebase({
    required String name,
    required String email,
  }) async {
    // Get current uid
    String uid = _auth.currentUser!.uid;

    // Extract username from email
    String username = email.split('@')[0];

    // Create a user profile
    Userprofile user = Userprofile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
    );

    // Convert user into a map so that we can store in Firebase
    final userMap = user.toMap();

    // Save user info in Firebase
    await _db.collection("users").doc(uid).set(userMap);
  }

  // Get user info
  Future<Userprofile?> getUserFromFirebase(String uid) async {
    try {
      // Retrieve user doc from Firebase
      DocumentSnapshot userDoc = await _db.collection("users").doc(uid).get();

      // Convert doc to user profile
      return Userprofile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /*
    USER STREAM
  */

  // Get a stream of all users
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _db.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Get data for each user
        final user = doc.data();

        // Add the document ID to the user data
        user['id'] = doc.id;

        // Return user data as a Map
        return user;
      }).toList();
    });
  }

  /*
    POST MESSAGE
  */

  // Post a message
  Future<void> postMessageInFirebase(String message) async {
    try {
      print("📢 postMessageInFirebase() Called!");

      // Get the current user's UID
      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        print("🚨 Error: User is not logged in.");
        return;
      }

      print("👤 Logged in User ID: $uid");

      // Get user details from Firestore
      Userprofile? user = await getUserFromFirebase(uid);
      if (user == null) {
        print("🚨 Error: User profile not found.");
        return;
      }

      print("✅ User Found: ${user.name}");

      // Create a new post using the Post class
      Post newPost = Post(
        id: '', // Firestore will generate this
        uid: uid,
        name: user.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );

      print("📝 Creating Post: ${newPost.message}");

      // Convert Post object to Map
      Map<String, dynamic> newPostMap = newPost.toMap();

      // Add post to Firestore
      DocumentReference docRef = await _db.collection("Posts").add(newPostMap);

      // Update post ID in Firestore
      await docRef.update({'id': docRef.id});

      print("✅ Post successfully added with ID: ${docRef.id}");
    } catch (e) {
      print("❌ Error posting message: $e");
    }
  }

  /*
    CHAT MESSAGES
  */

  // Send a message
  Future<void> sendMessage(String receiverID, String message) async {
    try {
      // Get current user info
      final String currentUserId = _auth.currentUser!.uid;
      final String currentUserEmail = _auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // Create a new message
      Message newMessage = Message(
        senderID: currentUserId,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
      );

      // Construct chat room ID for the two users (sorted to ensure uniqueness)
      List<String> ids = [currentUserId, receiverID];
      ids.sort(); // Sort the ids (this ensures the chatRoomID is the same for any 2 people)
      String chatRoomID = ids.join('_');

      // Add new message to the database
      await _db
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());

      print("Message sent successfully");
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // Construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _db
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /*
    OTHER METHODS
  */

  // Get all posts from Firebase
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection("Posts").get();
      return querySnapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      print("❌ Error fetching posts: $e");
      return [];
    }
  }
}