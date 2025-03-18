import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final int likeCount;
  final List<String> likedBy;
  final String imageUrl;

  Post({
    required this.id,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.likeCount,
    required this.likedBy,
    required this.imageUrl
  });

  // Convert Firestore Document to Post object
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id, // Firestore document ID
      uid: doc['uid'] ?? '',
      name: doc['name'] ?? '',
      username: doc['username'] ?? '',
      message: doc['message'] ?? '',
      timestamp: doc['timestamp'] ?? Timestamp.now(),
      likeCount: doc['likes'] ?? 0, // Fix: should match Firestore field
      likedBy: List<String>.from(doc['likedBy'] ?? []),
      imageUrl: doc['imageUrl'] ?? '',
    );
  }

  // Convert Post Object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Ensure ID is stored
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'likes': likeCount,
      'likedBy': likedBy,
    };
  }
}