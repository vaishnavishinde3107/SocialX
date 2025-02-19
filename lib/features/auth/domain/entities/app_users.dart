class AppUsers {
  final String uid;
  final String email;
  final String name;

  AppUsers({required this.uid, required this.email, required this.name});

  //convert app user to json
  Map<String, dynamic> toJson(){
    return{
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  //convert json to app user
  factory AppUsers.fromJson(Map<String, dynamic> jsonUser){
    return AppUsers(
      uid: jsonUser['uid'], 
      email: jsonUser['email'], 
      name: jsonUser['name']);
  }
}