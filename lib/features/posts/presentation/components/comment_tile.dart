import 'package:flutter/material.dart';

import '../../domain/entities/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          //name
          Text(comment.userName,
            style: const TextStyle(
                fontWeight: FontWeight.bold
            ),),

          const SizedBox(width: 10,),

          //comment text
          Text(comment.text),
        ],
      ),
    );
  }
}
