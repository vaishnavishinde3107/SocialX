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
  final ScrollController _scrollController = ScrollController(); // scroll to bottom when message is sent

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
        scrollToBottom();
    });
  }

  void scrollToBottom(){
    if(_scrollController.hasClients){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void sendMessage() async{
    //only send message if there is something to send
    if(_messageController.text.isNotEmpty){
      await _db.sendMessage(
          widget.receiverUserID,
          _messageController.text
      );

      //clear the text controller after sending the message
      _messageController.clear();
      //scroll to bottom
      scrollToBottom();
    }
  }

  void showUnsendMessage(String messageId) {
    showDialog(
        context: context, 
        builder: (context)=> AlertDialog(
          title: const Text("Unsend Message"),
          content: const Text("Do you want to unsend this message?"),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                child: const Text('Cancel')),
            TextButton(
                onPressed: () async {
                  // Construct the correct path to the message
                  String chatRoomId = widget.receiverUserID.compareTo(_auth.currentUser!.uid) > 0
                      ? "${_auth.currentUser!.uid}_${widget.receiverUserID}"
                      : "${widget.receiverUserID}_${_auth.currentUser!.uid}";

                  await FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(chatRoomId)
                      .collection('messages')
                      .doc(messageId)
                      .delete();

                  Navigator.pop(context);
                },
                child: const Text('Unsend', style: TextStyle(color: Colors.redAccent),))
          ],
        ));
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

          const SizedBox(height: 25,)
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(); // Automatically scroll down when chats are loaded and opened
        });


        // Debug: Log the data received
        print('Snapshot Data: ${snapshot.data!.docs.length} messages found');
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((document) {
            //print("Message data: ${document.data()}");  // Debugging the message data
            return _buildMessageItem(document);
          }).toList(),
        );
      },
    );
  }


//build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //print("Message data: $data");  // Debugging the data

    //align the messages to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderID'] == _auth.currentUser!.uid) ?
    Alignment.centerRight :
    Alignment.centerLeft;

    //convert timestamp into readable data
    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();
    String formattedTimestamp = "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onLongPress: (){
        if(data['senderID']== _auth.currentUser!.uid){
          showUnsendMessage(document.id);
        }
      },
      child: Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
            (data['senderID'] == _auth.currentUser!.uid)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: (data['senderID'] == _auth.currentUser!.uid)
                ? MainAxisAlignment.end
            :MainAxisAlignment.start,
            children: [
              Text(data['senderEmail']),
               const SizedBox(height: 5,),
              ChatBubble(message: data['message']),
              const SizedBox(height: 5,),
              Text(formattedTimestamp,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),),
            ],
          ),
        ),
      ),
    );
  }

//build message input
Widget _buildMessageInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
