import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialx/features/chats/presentation/pages/display_user.dart';
import 'package:socialx/features/home/presentation/components/my_drawer.dart';
import 'package:socialx/features/posts/presentation/pages/upload_post_page.dart';
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
  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: ()=> Navigator.push(
                context, 
              MaterialPageRoute(builder: (context)=> UploadPostPage())
              ),
              icon: const Icon(Icons.add_a_photo_outlined)),
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
      drawer: const MyDrawer(),
    );
  }
}

