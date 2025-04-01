import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resky/core/constants/constants.dart';
import 'package:resky/models/comment_model.dart';
import 'package:resky/controller/posts_controller.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import "package:routemaster/routemaster.dart";
import 'package:resky/controller/auth_controller.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final int depth;
  final int limit;
  final String type;
  final String? leader;

  const CommentCard({
    super.key,
    required this.comment,
    required this.depth,
    this.limit = 3,
    this.type = 'Post',
    this.leader,
  });

  void deleteComment(
      WidgetRef ref, BuildContext context, String commentId) async {
    ref.read(postControllerProvider.notifier).deleteComment(comment, context);
  }

  void upvoteComm(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvoteComm(comment);
  }

  void downvoteComm(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvoteComm(comment);
  }

  void navToAddComment(BuildContext context, String commentId) {
    Routemaster.of(context)
        .push('/post/${comment.postId}/comments/${commentId}');
  }

void showAlertDialog(WidgetRef ref, BuildContext context) {
  bool hasSpecialChar = comment.text.contains('¤');

  RegExp pattern = RegExp(r'\b(task|module)(?:\s+\d+)+\b', caseSensitive: false);
  Iterable<RegExpMatch> matches = pattern.allMatches(comment.text);
  String matchedTasks = matches.map((m) => m.group(0)!).join(', ');

  Widget continueButton = TextButton(
    child: const Text("No"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget cancelButton = TextButton(
    child: const Text("Yes"),
    onPressed: () {
      Navigator.of(context).pop();
      deleteComment(ref, context, comment.id);
    },
  );

  AlertDialog alert = AlertDialog(
    title: const Text("Delete Comment"),
    content: Text(hasSpecialChar
        ? "Are you sure you want to delete this comment?"
        : (matchedTasks.isNotEmpty
            ? "Are you sure you want to delete this comment related to $matchedTasks?"
            : "Are you sure you want to delete this comment?")),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


  Widget displayComments(BuildContext context, Comment comment, int depth,
      String type, int limit) {
    if (type == 'Post') {
      if (depth == limit) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommentCard(comment: comment, depth: depth + 2, leader: leader),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => navToAddComment(context, comment.id),
                    child: const Text('View All Replies'),
                  ),
                ),
              ],
            ),
          ],
        );
      } else if (depth > limit + 1) {
        return Container();
      }

      return CommentCard(comment: comment, depth: depth + 1);
    } else if (type == 'Comment') {
      if (depth >= limit) {
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => navToAddComment(context, comment.id),
                child: const Text('View All Replies'),
              ),
            ),
          ],
        );
      }
      return CommentCard(
          comment: comment, depth: depth + 1, limit: 6, type: 'Comment');
    }
    return Container();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    DateTime now = comment.createdAt;
    String getTimeAgo(DateTime date) {
  final Duration diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 30) return '${diff.inDays}d';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}m';
  return '${(diff.inDays / 365).floor()}y';
}

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(24, 158, 158, 158), // Colors.grey.shade300
        border: Border(
          top: const BorderSide(
            color: Colors.white,
            width: 0.5,
          ),
          left: const BorderSide(
            color: Colors.white,
            width: 0.5,
          ),
          right: const BorderSide(
            color: Colors.white,
            width: 0,
          ),
          bottom: BorderSide(
            color: Colors.white,
            width: depth > limit ? 0.5 : 0,
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          bottomLeft: depth > limit
              ? const Radius.circular(12)
              : const Radius.circular(0),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  comment.profilePic,
                ),
                radius: 15,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
    Row(children:[
      (user.name == comment.username) ? Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(10), 
  ),
  child: Text(
    comment.username,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
) : Text(
      comment.username,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
   (leader == comment.username && leader != null) ?  Text(" • Team Leader",style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),)
    : Text(" • ${user.role}",style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),),
    
    ]),
    Text(
  "${getTimeAgo(comment.createdAt)} ago",
  style: const TextStyle(fontSize: 13, color: Colors.black54),
),

  ],
              ),
            ]),
            if (comment.uid == user.uid)
              IconButton(
                  onPressed: () => showAlertDialog(ref, context),
                  icon: const Icon(Icons.delete, color: Colors.red)),
          ],
        ),
        const SizedBox(height: 10),
        wrapHighlightedText(comment.text),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => navToAddComment(context, comment.id),
              icon: const Icon(Icons.reply_outlined, size: 20),
            ),
            GestureDetector(
              onTap: () => navToAddComment(context, comment.id),
              child: const Text(
                'Reply',
                style: TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => upvoteComm(ref),
              icon: Icon(
                  comment.upvotes.contains(user.uid)
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  size: 20,
                  color: comment.upvotes.contains(user.uid)
                      ? Colors.red
                      : Colors.black),
            ),
            SizedBox(
              width: 21,
              child: Center(
                child: Text(
                  '${comment.upvotes.length - comment.downvotes.length == 0 ? '0' : comment.upvotes.length - comment.downvotes.length}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            IconButton(
              onPressed: () => downvoteComm(ref),
              icon: Icon(
                  comment.downvotes.contains(user.uid)
                      ? Icons.heart_broken_rounded
                      : Icons.heart_broken_outlined,
                  size: 20,
                  color: Colors.black),
            ),
          ],
        ),
        const SizedBox(),
        ref.watch(getCommentRepliesProvider(comment.id)).when(
              data: (data) {
                return Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.isEmpty)
                        Container()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final replyComment = data[index];
                            return Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: displayComments(
                                  context, replyComment, depth, type, limit),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
              error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => const Loader(),
            ),
      ]),
    );
  }
}

Widget wrapHighlightedText(String text) {
  bool hasSpecialChar = text.contains("¤");
  text = text.replaceAll("¤", ""); 

  if (hasSpecialChar) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }

  RegExp pattern = RegExp(r'\b(task|module)(?:\s+\d+)+\b', caseSensitive: false);
  List<InlineSpan> spans = [];
  int start = 0;

  for (RegExpMatch match in pattern.allMatches(text)) {
    if (match.start > start) {
      spans.add(TextSpan(text: text.substring(start, match.start)));
    }

    spans.add(
      WidgetSpan(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text.substring(match.start, match.end),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    start = match.end;
  }

  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return RichText(
    text: TextSpan(
      children: spans,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    ),
  );
}


