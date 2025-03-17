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
  // Widget _buildUserList(){
  //   return StreamBuilder(
  //     stream: _db.getUserStream(),
  //     builder: (context, snapshot){
  //       //error
  //       if (snapshot.hasError) {
  //         return const Text('Error');
  //       }
  //
  //       //loading
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Text("Loading...");
  //       }
  //
  //       //return list View
  //       return ListView(
  //         children: snapshot.data!.map<Widget>((userData)=> _buildUserListItem(userData, context)).toList(),
  //       );
  //
  //     });
  // }

  //build individual list title for user

    Widget _buildUserList() {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: _db.getUserStream(),
        builder: (context, snapshot) {
          // Error case
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users.'));
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if data exists
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          // DEBUG LOGGING
          print("Fetched Users: ${snapshot.data}");

          // Return list
          return ListView(
            children: snapshot.data!.map<Widget>((userData) {
              return _buildUserListItem(userData, context);
            }).toList(),
          );
        },
      );
    }


  //   Widget _buildUserListItem(Map<String, dynamic>userData, BuildContext context){
  //
  //   // Get the current user's email
  //   String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  //
  //   //display all the users except current user
  //   if (userData['email']!= currentUserEmail) {
  //     return UserTile(
  //     text: userData['email'],
  //     onTap: () {
  //       //tapped on a user-> go to chat page
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context)=> ChatPage(receiverUserEmail: userData["email"], receiverUserID: userData['uid'],)));
  //      },);
  //   }else{
  //   return Container();
  // }
  // }

    Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      // DEBUG LOGGING
      print("Checking user: ${userData['email']} (Current: $currentUserEmail)");

      if (userData['email'] != null && userData['email'] != currentUserEmail) {
        return UserTile(
          text: userData['email'],
          onTap: () {
            print("Tapped on user: ${userData['email']}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: userData["email"],
                  receiverUserID: userData['uid'],
                ),
              ),
            );
          },
        );
      } else {
        return Container(); // Hide current user
      }
    }

}