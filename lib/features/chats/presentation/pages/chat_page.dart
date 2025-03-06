import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialx/features/auth/presentation/components/my_textfield.dart';
import 'package:socialx/features/chats/presentation/components/chat_bubble.dart';
import 'package:socialx/services/database/database_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage({super.key, required this.receiverUserEmail, required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage() async{
    //only send message if there is something to send
    if(_messageController.text.isNotEmpty){
      await _db.sendMessage(
          widget.receiverUserID,
          _messageController.text);

      //clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
      ),
      body: Column(
        children: [
          //messages
          Expanded(
              child: _buildMessageList()
          ),

          //user input
          _buildMessageInput(),

          SizedBox(height: 25,)
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getMessages(widget.receiverUserID, _auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');  // Log any error that occurs
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading...');  // Log loading state
          return const Center(child: CircularProgressIndicator());
        }

        // Debug: Check if we have data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No messages found!');
          return const Center(child: Text('No messages yet.'));
        }

        // Debug: Log the data received
        print('Snapshot Data: ${snapshot.data!.docs.length} messages found');
        return ListView(
          children: snapshot.data!.docs.map((document) {
            print("Message data: ${document.data()}");  // Debugging the message data
            return _buildMessageItem(document);
          }).toList(),
        );
      },
    );
  }


//build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    print("Message data: $data");  // Debugging the data

    //align the messages to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderEmail'] == _auth.currentUser!.uid) ?
    Alignment.centerRight :
    Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
          (data['senderEmail'] == _auth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderEmail'] == _auth.currentUser!.uid)
              ? MainAxisAlignment.end
          :MainAxisAlignment.start,
          children: [
            Text(data['senderID']),
            SizedBox(height: 5,),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }

//build message input
Widget _buildMessageInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          //textField
          Expanded(
              child: MyTextfield(
                  controller: _messageController,
                  hintText: 'Enter message',
                  obscuretext: false),
          ),

          //send button
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send))
        ],
      ),
    );
}

}
