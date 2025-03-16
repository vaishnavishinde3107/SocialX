import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String test;
  final String imageUrl;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.test,
    required this.imageUrl,
    required this.timestamp
});

  Post copyWith({String? imageUrl }){
    return Post(
        id: id,
        userId: userId,
        userName: userName,
        test: test,
        imageUrl: imageUrl ?? this.imageUrl,
        timestamp: timestamp);
  }
  // convert post -> Json
Map<String, dynamic> toJson(){
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'test': test,
      'imageUrl': imageUrl,
      'timestamp': timestamp
    };
}

  // convert Json -> post
factory Post.fromJson(Map<String, dynamic> json){
    return Post(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        test: json['test'],
        imageUrl: json['imageUrl'],
        timestamp: (json['timestamp'] as Timestamp).toDate());
  }
}