import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialx/features/chats/presentation/components/user_tile.dart';
import 'package:socialx/features/chats/presentation/pages/chat_page.dart';
import 'package:socialx/services/database/database_service.dart';

class DisplayUser extends StatelessWidget {
    DisplayUser({super.key});

   final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display user page'),
      ),
      body: _buildUserList(),
    );
  }

  //build the list of users and display it except the logged in in user
  Widget _buildUserList(){
    return StreamBuilder(
      stream: _db.getUserStream(), 
      builder: (context, snapshot){
        //error
        if (snapshot.hasError) {
          return const Text('Error');
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        //return list View
        return ListView(
          children: snapshot.data!.map<Widget>((userData)=> _buildUserListItem(userData, context)).toList(),
        );

      });
  }

  //build individual list title for user
  Widget _buildUserListItem(Map<String, dynamic>userData, BuildContext context){
    //display all the users except current user
    if (userData['email']!= _db.getUserStream()) {
      return UserTile(
      text: userData['email'], 
      onTap: () {
        //tapped on a user-> go to chat page
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context)=> ChatPage(receiverEmail: userData["email"])));
       },);
    }else{
    return Container();
  }
  } 
}