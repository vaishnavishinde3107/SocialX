import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/app.dart';
import 'package:socialx/features/auth/domain/entities/app_users.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialx/features/posts/presentation/cubits/post_cubit.dart';

import '../../domain/entities/post.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/cubits/profile_cubits.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  //current user
  AppUsers? currentUser;

  // post User
  ProfileUser? postUser;

  //on startup
  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser(){
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentuser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async{
    final fetchUser = await profileCubit.getUserProfile(widget.post.userId);
    if(fetchUser != null){
      setState(() {
        postUser = fetchUser;
      });
    }
  }

  /*
  * Likes
  * */

  //user tapped like button
  void toggleLikePost() {
    //current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    //optimistically like and & update UI
    setState(() {
      if(isLiked){
        widget.post.likes.remove(currentUser!.uid); //unlike
      } else {
        widget.post.likes.add(currentUser!.uid); // like
      }
    });

    //update like
    postCubit.toggleLikedPost(widget.post.id, currentUser!.uid).catchError((error){
      //if theres an error revert back to original value
      setState(() {
        if(isLiked){
          widget.post.likes.add(currentUser!.uid); // revert unlike
        } else {
          widget.post.likes.remove(currentUser!.uid); // revert like
        }
      });

    });
  }

  // Show options for deletion
  void showOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // Delete button
          TextButton(
            onPressed: () {
              widget.onDeletePressed?.call();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("User Name: ${widget.post.userName}");
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // Name
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              //top selection: profile pic? name/ delete
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //profile pic
                postUser?.profileImageUrl != null? CachedNetworkImage(
                    imageUrl: postUser!.profileImageUrl,
                errorWidget: (context, url, error)=> const Icon(Icons.person),
                  imageBuilder: (context, imageProvider)=> Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider,
                        fit: BoxFit.cover
                      ),
                    ),
                  ),
                ) : const Icon(Icons.person),

                const SizedBox(width: 10,),

                //name
                Text(
                  postUser?.name ?? widget.post.userName, // Fallback to widget.post.userName if postUser is null
                  style: const TextStyle(
                      color: Colors.black
                  ),
                ),

                const Spacer(),

                // Delete button
                if(isOwnPost)
                  IconButton(
                    onPressed: showOption,
                    icon: const Icon(Icons.delete,),
                  ),
              ],
            ),
          ),

          // Image
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 420,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 430),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          //buttons -> Like, comment, timestamp
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: toggleLikePost,
                    child: Icon(
                      widget.post.likes.contains(currentUser!.uid)
                        ? Icons.favorite
                      : Icons.favorite_border,
                    )),

                Text(widget.post.likes.length.toString()),

                const SizedBox(width: 20,),

                // comment button
                const Icon(Icons.comment),

                Text('0'),

                const Spacer(),

                //timestamp
                Text(widget.post.timestamp.toString()),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
