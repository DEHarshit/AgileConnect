import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/auth_controller.dart';
import 'package:resky/controller/community_controller.dart';
import 'package:resky/controller/posts_controller.dart';
import 'package:resky/core/constants/constants.dart';
import 'package:resky/models/post_model.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import 'package:resky/pages/comp/post_image.dart';
import 'package:resky/controller/reports_controller.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final String? reportId;
  const PostCard({
    super.key,
    required this.post,
    this.reportId,
  });

  void deletePost(WidgetRef ref, BuildContext context, String postId) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
    ref
        .read(reportControllerProvider.notifier)
        .deleteModReport(postId, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void navToUser(BuildContext context) {
    Routemaster.of(context).push('/user/${post.uid}');
  }

  void navToCommunity(BuildContext context) {
    Routemaster.of(context).push('/${post.communityName}');
  }

  void navToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  void reportPost(BuildContext context, WidgetRef ref, String userId) {
    TextEditingController reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Post"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter the reason for reporting this post:'),
              const SizedBox(height: 10),
              TextField(
                controller: reportController,
                decoration: const InputDecoration(
                  hintText: 'Enter reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final reportReason = reportController.text;
                if (reportReason.isNotEmpty) {
                  submitReport(context, ref, userId, reportReason);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for reporting.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // report submission
  void submitReport(
      BuildContext context, WidgetRef ref, String userId, String reason) {
    //firebase logic :<
    ref.read(reportControllerProvider.notifier).shareReport(
          context: context,
          text: reason,
          communityName: post.communityName,
          postId: post.id,
          type: 'post',
        );
  }

  void showAlertDialog(WidgetRef ref, BuildContext context) {
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
        deletePost(ref, context, post.id);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Post"),
      content: const Text("Are you sure you want to delete this post?"),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.link != null;
    final isTypeText = post.description != null;
    final user = ref.watch(userProvider)!;
    String getTimeRemaining(int endsAt) {
  if (endsAt == 0) return 'Unknown';

  final now = DateTime.now();
  final endTime = DateTime.fromMillisecondsSinceEpoch(endsAt);
  final duration = endTime.difference(now);

  if (duration.isNegative) return 'Ended';

  if (duration.inMinutes < 1) {
    return 'less than a minute';
  } else if (duration.inHours < 1) {
    return '${duration.inMinutes} minutes';
  } else if (duration.inDays < 1) {
    return '${duration.inHours} hours';
  } else {
    return '${duration.inDays} days';
  }
}

    
    if (reportId != null) {
      return GestureDetector(
          onTap: () => navToComments(context),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => navToCommunity(context),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                post.communityProfile),
                                            radius: 16,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    68, 158, 158, 158),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.communityId,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                              //username

                                              post.isAnonymous
                                                  ? const Text(
                                                      'Anonymous',
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () =>
                                                          navToUser(context),
                                                      child: Text(
                                                        post.username,
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    //delete icon

                                    ref
                                        .watch(getCommunityByNameProvider(
                                            post.communityName))
                                        .when(
                                            data: (data) {
                                              if (data.mods
                                                  .contains(user.uid)) {
                                                return ElevatedButton(
                                                  onPressed: () =>
                                                      showAlertDialog(
                                                          ref, context),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .redAccent, // Background color
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30), // Rounded corners
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.delete_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Delete Post',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                            error: (error, stackTrace) =>
                                                ErrorText(
                                                  error: error.toString(),
                                                ),
                                            loading: () => const Loader())
                                  ],
                                ),
                                if (isTypeText)
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 17),
                                      child: Text(post.description!,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ),
                                  ),
                                if (isTypeText && isTypeImage)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                if (isTypeImage)
                                  GestureDetector(
                                    onTap: () {
                                    Routemaster.of(context).push(
                                      '/post/${post.id}/image/',
                                    );
                                  },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: const Color.fromARGB(
                                                68, 158, 158, 158)),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(11)),
                                      ),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.45,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          child: CachedNetworkImage(
                                            imageUrl: post.link!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              Constants.logoPath,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ));
    } else {
      return (getTimeRemaining(post.endsAt?.millisecondsSinceEpoch ?? 0) == "Ended")? Column(children:[
        Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      width: 0.5,
      color: Color.fromARGB(68, 158, 158, 158),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 3,
        spreadRadius: 1,
        offset: Offset(0, 3),
      ),
    ],
  ),
  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                           Row(
  children: [
    Text(
      "SESSION",
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 8),
    Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.blue, 
    borderRadius: BorderRadius.circular(8), 
  ),
  child: Text(
    '${getTimeRemaining(post.endsAt?.millisecondsSinceEpoch ?? 0)}',
    style: const TextStyle(
      fontSize: 16,
      color: Colors.white, 
      fontWeight: FontWeight.bold,
    ),
  ),
),

  ],
),


                                            //username

                                            post.isAnonymous
                                                ? const Text(
                                                    'Anonymous',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  )
                                                : GestureDetector(
                                                    onTap: () =>
                                                        navToUser(context),
                                                    child: Text(
                                                      'by ${post.username}`',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
  onPressed: () => showModalBottomSheet(
    context: context,
    builder: (context) => Wrap(
      children: [
        ref
                                      .watch(getCommunityByNameProvider(
                                          post.communityName))
                                      .when(
                                          data: (data) {
                                            if (data.mods.contains(user.uid)) {
                                              return  ListTile(
                                                leading: const Icon(Icons.delete_forever_outlined,color: Colors.black),
                                                    title: const Text("Delete Post (Moderator)"),
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      showAlertDialog(ref, context);
                                                    }
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                          error: (error, stackTrace) =>
                                              ErrorText(
                                                error: error.toString(),
                                              ),
                                          loading: () => const Loader()),
        ListTile(
          leading: const Icon(Icons.menu, color: Colors.black54),
            title: const Text("Show Session Participants"),
            onTap: () {
              Navigator.pop(context);
              reportPost(context, ref, user.uid);
            },
        ),
        if (post.uid == user.uid)
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text("Delete Post"),
          onTap: () {
            Navigator.pop(context);
            showAlertDialog(ref, context);
          },
        ),
        if (post.uid != user.uid)
          ListTile(
            leading: const Icon(Icons.report, color: Colors.orange),
            title: const Text("Report Post"),
            onTap: () {
              Navigator.pop(context);
              reportPost(context, ref, user.uid);
            },
          ),
        
      ],
    ),
  ),
  icon: const Icon(Icons.more_vert, color: Colors.black),
),
                                    ],
                                  ),

                                ],
                              ),
                              if (isTypeText)
                                  SizedBox(height:10),
                              Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 17),
                                      child: Text("Summary of ${post.title!}",
                                          style: const TextStyle(
                                              color: Colors.black,fontSize: 20)),
                                    ),
                                  ),
                                  SizedBox(height:10),
                                  
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17),
                                    child: Text(post.manualSummary!,
                                        style: const TextStyle(
                                            color: Colors.black)),
                                  ),
                                ),
                              /* if (isTypeText && isTypeImage) */
                              const SizedBox(
                                height: 10,
                              ),
                                ],
                              ),
                            )]))]))]):GestureDetector(
        onTap: () => navToComments(context),
        child: Column(
          children: [
            Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      width: 0.5,
      color: Color.fromARGB(68, 158, 158, 158),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 3,
        spreadRadius: 1,
        offset: Offset(0, 3),
      ),
    ],
  ),
  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                           Row(
  children: [
    Text(
      "SESSION",
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 8),
    Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.blue, 
    borderRadius: BorderRadius.circular(8), 
  ),
  child: Text(
    'Ends in ${getTimeRemaining(post.endsAt?.millisecondsSinceEpoch ?? 0)}',
    style: const TextStyle(
      fontSize: 14,
      color: Colors.white, 
      fontWeight: FontWeight.bold,
    ),
  ),
),

  ],
),


                                            //username

                                            post.isAnonymous
                                                ? const Text(
                                                    'Anonymous',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  )
                                                : GestureDetector(
                                                    onTap: () =>
                                                        navToUser(context),
                                                    child: Text(
                                                      'by ${post.username}`',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  //delete icon
                                  IconButton(
  onPressed: () => showModalBottomSheet(
    context: context,
    builder: (context) => Wrap(
      children: [
                                      ref
                                      .watch(getCommunityByNameProvider(
                                          post.communityName))
                                      .when(
                                          data: (data) {
                                            if (data.mods.contains(user.uid)) {
                                              return  ListTile(
                                                leading: const Icon(Icons.delete_forever_outlined,color: Colors.black),
                                                    title: const Text("Delete Post (Moderator)"),
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                      showAlertDialog(ref, context);
                                                    }
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                          error: (error, stackTrace) =>
                                              ErrorText(
                                                error: error.toString(),
                                              ),
                                          loading: () => const Loader()),
        ListTile(
          leading: const Icon(Icons.menu, color: Colors.black54),
            title: const Text("Show Session Participants"),
            onTap: () {
              Navigator.pop(context);
              reportPost(context, ref, user.uid);
            },
        ),
        if (post.uid == user.uid)
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text("Delete Post"),
          onTap: () {
            Navigator.pop(context);
            showAlertDialog(ref, context);
          },
        ),
        if (post.uid != user.uid)
          ListTile(
            leading: const Icon(Icons.report, color: Colors.orange),
            title: const Text("Report Post"),
            onTap: () {
              Navigator.pop(context);
              reportPost(context, ref, user.uid);
            },
          ),
      ],
    ),
  ),
  icon: const Icon(Icons.more_vert, color: Colors.black),
),
                                ],
                              ),
                              if (isTypeText)
                                  SizedBox(height:10),
                              Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 17),
                                      child: Text(post.title!,
                                          style: const TextStyle(
                                              color: Colors.black,fontSize: 20)),
                                    ),
                                  ),
                                  SizedBox(height:10),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17),
                                    child: Text(post.description!,
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ),
                                ),
                              /* if (isTypeText && isTypeImage) */
                              const SizedBox(
                                height: 10,
                              ),
                              if (isTypeImage)
                                GestureDetector(
                                  onTap: () {
                                    Routemaster.of(context).push(
                                      '/post/${post.id}/image/',
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              68, 158, 158, 158)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(11)),
                                    ),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.45,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        child: CachedNetworkImage(
                                          imageUrl: post.link!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            Constants.logoPath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isTypeImage)
                                const SizedBox(
                                  height: 10,
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 35,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: const Color.fromARGB(
                                                  68, 158, 158, 158)),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100)),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () => upvotePost(ref),
                                              icon: Icon(
                                                  post.upvotes
                                                          .contains(user.uid)
                                                      ? Icons.favorite
                                                      : Icons.favorite_outline,
                                                  size: 20,
                                                  color: post.upvotes
                                                          .contains(user.uid)
                                                      ? Colors.red
                                                      : Colors.black),
                                            ),
                                            Text(
                                              '${post.upvotes.length - post.downvotes.length == 0 ? '0' : post.upvotes.length - post.downvotes.length}',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  downvotePost(ref),
                                              icon: Icon(
                                                  post.downvotes
                                                          .contains(user.uid)
                                                      ? Icons
                                                          .heart_broken_rounded
                                                      : Icons
                                                          .heart_broken_outlined,
                                                  size: 20,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        height: 35,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    68, 158, 158, 158),
                                                width: 1),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100))),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  navToComments(context),
                                              icon: Icon(
                                                  post.commentCount == 0
                                                      ? Icons
                                                          .chat_bubble_outline_outlined
                                                      : Icons
                                                          .comment_bank_outlined,
                                                  size: 20,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              '${post.commentCount == 0 ? 'Disccusion' : post.commentCount}',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(width: 17)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  //mod tool

                                  
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
