import 'package:cloud_firestore/cloud_firestore.dart';


class Post {
  final String id;
  late final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes; //store uids

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
});

  Post copyWith({String? imageUrl }){
    return Post(
        id: id,
        userId: userId,
        userName: userName,
        text: text,
        imageUrl: imageUrl ?? this.imageUrl,
        timestamp: timestamp,
        likes: likes,
    );
  }
  // convert post -> Json
Map<String, dynamic> toJson(){
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'likes': likes,
    };
}

  // convert Json -> post
factory Post.fromJson(Map<String, dynamic> json){
    return Post(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        text: json['text'],
        imageUrl: json['imageUrl'],
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        likes: List<String>.from(json['likes'] ?? []),
    );
  }
}