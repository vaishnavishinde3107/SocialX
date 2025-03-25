import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialx/models/post.dart';

class DatabaseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Local list to hold all posts
  final List<Post> _allPosts = [];
  List<Post> get allPosts => _allPosts;

  // Fetch current user data
  Future<Map<String, dynamic>?> getCurrentUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('Users').doc(userId).get();

      if (snapshot.exists) {
        return snapshot.data();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  // Method to post a message to Firebase
  Future<void> postMessageInFirebase({
    required String uid,
    required String name,
    required String username,
    required String message,
    required String imageUrl,
  }) async {
    try {
      // Check if the user is authenticated
      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        print("Error: User is not authenticated.");
        return;
      }

      if (message.isEmpty) {
        print("Error: Message cannot be empty.");
        return;
      }

      await _firestore.collection('Posts').add({
        'uid': uid,
        'name': name,
        'username': username,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'imageUrl': imageUrl,
      });

      print("Post successfully added!");
      await fetchAllPosts(); // Refresh posts after posting
    } catch (error) {
      print("Error posting message: $error");
    }
  }

  // Method to fetch all posts from Firebase
  Future<void> fetchAllPosts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();

      _allPosts.clear();
      //_allPosts.addAll(snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
      notifyListeners();
      print("Posts fetched successfully! Total: ${_allPosts.length}");
    } catch (error) {
      print("Error fetching posts: $error");
    }
  }
}
