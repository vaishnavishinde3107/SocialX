import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/app.dart';
import 'package:socialx/features/auth/domain/entities/app_users.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialx/features/posts/presentation/cubits/post_cubit.dart';

import '../../domain/entities/comment.dart';


class CommentTile extends StatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {

  // current user
  AppUsers? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser(){
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentuser;
    isOwnPost = widget.comment.userId == currentUser!.uid;
  }

  // show option for delete
  void showOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment?'),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // Delete button
          TextButton(
            onPressed: () {
              context.read<PostCubit>().deleteComment(widget.comment.postId, widget.comment.id);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          //name
          Text(widget.comment.userName,
            style: const TextStyle(
                fontWeight: FontWeight.bold
            ),),

          const SizedBox(width: 10,),

          //comment text
          Text(widget.comment.text),

          const Spacer(),

          //delete button
          if (isOwnPost)
            GestureDetector(
              onTap: showOption,
              child: Icon(Icons.more_horiz,
              color: Theme.of(context).colorScheme.primary,),
            ),

        ],
      ),
    );
  }
}

  
