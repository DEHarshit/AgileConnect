import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resky/core/constants/constants.dart';
import 'package:resky/models/comment_model.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController replyController = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  comment.profilePic,
                ),
                radius: 15,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
                controller: replyController,
                decoration: const InputDecoration(
                  hintText: 'Enter reason',
                  border: OutlineInputBorder(),
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.reply),
              ),
              const Text('Send', style: TextStyle(fontSize: 17)),
            ],
          ),
          const SizedBox(),
          const Divider(
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
