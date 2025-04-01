import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resky/controller/posts_controller.dart';
import 'package:resky/pages/comp/comment.card.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import 'package:resky/models/comment_model.dart';

class AddCommentsScreen extends ConsumerStatefulWidget {
  final String commentId;
  const AddCommentsScreen({
    super.key,
    required this.commentId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddCommentsScreenState();
}

class _AddCommentsScreenState extends ConsumerState<AddCommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(String commentId) {
    final comment = ref.read(getCommentByIdProvider(commentId)).requireValue;
    String type = 'comment';
    ref.read(postControllerProvider.notifier).addReply(
          context: context,
          text: commentController.text.trim(),
          post: comment,
          type: type,
        );
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final comment = ref.watch(getCommentByIdProvider(widget.commentId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies'),
        leading: IconButton(
          icon: const Icon(Icons.comment_bank_sharp),
          onPressed: () {
          },
        ),
      ),
      body: comment.when(
        data: (comment) => SingleChildScrollView(
          child: Column(
            children: [
              CommentCard(
                  comment: comment, depth: 0, limit: 6, type: 'Comment'),
              const Divider(),
            ],
          ),
        ),
        loading: () => const Loader(),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          alignment: Alignment.center,
          height: 45,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            border: Border.all(
              color: Colors.blueAccent,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: SizedBox(
                  height: 35,
                  width: 50,
                  child: TextField(
                    style: const TextStyle(fontSize: 15),
                    controller: commentController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'What are your thoughts?',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  child: IconButton(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 7),
                      onPressed: () => addComment(widget.commentId),
                      icon: const Icon(Icons.send))),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}
