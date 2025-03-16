import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialx/features/chats/presentation/pages/display_user.dart';
import 'package:socialx/features/home/presentation/components/my_drawer.dart';
import 'package:socialx/services/database/database_provider.dart';

/*
 HOME PAGE
 This is the main page of this app: it displays a list of posts.
 */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //provider
late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

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
          final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

          // Post in database
          await postMessage(databaseProvider, _messageController.text);

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

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DisplayUser()),
              );
            },
            icon: const Icon(Icons.message),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        child: const Icon(Icons.add),
      ),
      drawer: const MyDrawer(),
    );
  }
}

// Define the MyInputAlertBox widget
class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final VoidCallback onPressed;
  final String onPressedText;

  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Post"),
      content: TextField(
        controller: textController,
        decoration: InputDecoration(hintText: hintText),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(onPressedText),
        ),
      ],
    );
  }
}