import 'package:flutter/material.dart';

import '../../../../services/database/database_provider.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../components/my_input_alertBox.dart';

class Twitter extends StatefulWidget {
  const Twitter({super.key});

  @override
  State<Twitter> createState() => _TwitterState();
}

class _TwitterState extends State<Twitter> {
  //provider
  //late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

  // Text controller
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Show Message Dialog Box
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _messageController,
        hintText: "Want To Share Something?",
        onPressed: () async {
          if (_messageController.text.trim().isEmpty) {
            return; // Prevent empty posts
          }

          // Close the dialog before performing the operation
          Navigator.pop(context);

          // Get provider instance
          //final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

          // Post in database
          //await postMessage(databaseProvider, _messageController.text);

          // Clear the text field after posting
          _messageController.clear();
        },
        onPressedText: "Post",
      ),
    );
  }

  // User wants to post message
  Future<void> postMessage(DatabaseProvider databaseProvider, String message) async {
    try {
      await databaseProvider.postMessage(message);
      print("Post uploaded successfully");
    } catch (e) {
      print("Error posting message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twitter Feeds'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        child: const Icon(Icons.add),
      ),
    );
  }
}
