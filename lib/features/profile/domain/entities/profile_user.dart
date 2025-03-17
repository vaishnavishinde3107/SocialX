import 'package:socialx/features/auth/domain/entities/app_users.dart';

class ProfileUser extends AppUsers {
  final String bio;
  final String profileImageUrl;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
  });

  //method to update profile user
  ProfileUser copyWith({String? newBio, String? newProfileImageUrl}){
    return ProfileUser(
      uid: uid, 
      email: email, 
      name: name, 
      bio: newBio ?? bio, 
      profileImageUrl: newProfileImageUrl ?? profileImageUrl);
  }

  //convert profile user-> json
  @override
  Map<String, dynamic> toJson(){
    return{
      'uid':uid,
      'email':email,
      'name': name,
      'bio':bio,
      'profileImageUrl': profileImageUrl,
    };
  }

  //convert json-> json user

  factory ProfileUser.fromJson(Map<String,dynamic> json){
    return ProfileUser(
      uid:json['uid'], 
      email: json['email'], 
      name: json['name'], 
      bio: json['bio'], 
      profileImageUrl: json['profileImageUrl']);
  }
}