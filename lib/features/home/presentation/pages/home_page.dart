import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:socialx/features/chats/presentation/pages/display_user.dart';
import 'package:socialx/features/home/presentation/components/my_drawer.dart';
import 'package:socialx/features/posts/presentation/components/post_tile.dart';
import 'package:socialx/features/posts/presentation/cubits/post_states.dart';
import 'package:socialx/features/posts/presentation/pages/upload_post_page.dart';
import '../../../posts/presentation/cubits/post_cubit.dart';

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

  //post cubit
  late final postCubit = context.read<PostCubit>();

  //on startup
  @override
  void initState() {
    super.initState();

    //fetch all posts
    fetchAllPosts();

  }

  void fetchAllPosts(){
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId){
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

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
              MaterialPageRoute(builder: (context)=> const UploadPostPage())
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

      body: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            //loading...
            if(state is PostsLoading && state is PostsUploading){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //loaded
            else if (state is PostsLoaded){
              final allPosts = state.posts;
              
              if(allPosts.isEmpty){
                return const Center(
                  child: Text('No posts available'),
                );
              }
              return ListView.builder(
                itemCount: allPosts.length,
                  itemBuilder: (context, index){
                    //get individual posts
                    final post = allPosts[index];

                    //image
                    return PostTile(
                      post: post,
                      onDeletePressed: () => deletePost(post.id),);
                  }
                  );
            }
            //error
            else if (state is PostsError){
              return Center(child: Text(state.message));
            } else {
              return const SizedBox();
            }
          }
      ),
    );
  }
}

