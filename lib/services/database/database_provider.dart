import 'package:flutter/foundation.dart';
import 'package:socialx/models/post.dart';
import 'package:socialx/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  /*
  SERVICES
   */
  final _db = DatabaseService();

  /*
  POSTS
   */
  // Local List of Posts
  final List<Post> _allPosts = [];

  // Getter to access posts
  List<Post> get allPosts => _allPosts;

  // Post message
  Future<void> postMessage(String message) async {
   // await _db.postMessageInFirebase(message); // Post to Firebase
    await fetchAllPosts(); // Refresh posts after posting
  }

  // Fetch all posts from Firebase
  Future<void> fetchAllPosts() async {
    try {
      //List<Post> fetchedPosts = await _db.getAllPostsFromFirebase();
      _allPosts.clear(); // Clear old posts
      //_allPosts.addAll(fetchedPosts); // Add new posts
      notifyListeners(); // Update UI
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching posts: $error");
      }
    }
  }
}