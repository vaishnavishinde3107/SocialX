
import 'package:socialx/features/posts/domain/entities/comment.dart';


class Post {
  final String id;
  late final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  //final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comment;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    //required this.timestamp,
    required this.likes,
    required this.comment,
  });

  Post copyWith({String? imageUrl }){
    return Post(
        id: id,
        userId: userId,
        userName: userName,
        text: text,
        imageUrl: imageUrl ?? this.imageUrl,
        //timestamp: timestamp,
        likes: likes,
      comment: comment,
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
      // 'timestamp': timestamp,
      'likes': likes,
      'comment': comment.map((comment)=> comment.toJson()).toList(),
    };
  }

  // convert Json -> post
  factory Post.fromJson(Map<String, dynamic> json){

    //prepare comments
    final List<Comment> comments =
        (json['comment'] as List<dynamic>?)?.map((commentJson)=>
            Comment.fromJson(commentJson)).toList() ?? [];

    return Post(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        text: json['text'],
        imageUrl: json['imageUrl'],
        // timestamp: (json['timestamp'] != null && json['timestamp'] is Timestamp)
        //     ? (json['timestamp'] as Timestamp).toDate()
        //     : DateTime.now(),
      likes: List<String>.from(json['likes'] ?? []),
        comment: comments
    );
  }
}