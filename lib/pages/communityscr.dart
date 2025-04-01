import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:routemaster/routemaster.dart";
import "package:resky/controller/auth_controller.dart";
import "package:resky/controller/community_controller.dart";
import "package:resky/controller/posts_controller.dart";
import "package:resky/models/community.dart";
import "package:resky/pages/comp/error_text.dart";
import "package:resky/pages/comp/loader.dart";
import "package:resky/pages/comp/post_card.dart";
import 'package:resky/core/utils.dart';

class CommunityScreen extends StatefulWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void navToTools(BuildContext context) {
    Routemaster.of(context).push('/${widget.name}/mod-tools');
  }

  void navToQuestion(BuildContext context) {
    Routemaster.of(context).push('/${widget.name}/question-paper');
  }

  void navToSessions(BuildContext context) {
    Routemaster.of(context).push('/${widget.name}/add-posts');
  }

  void joinDepartment(WidgetRef ref, Community department, BuildContext context) {
    ref.read(communityControllerProvider.notifier).joinDepartment(department, context);
  }

  void sharePost(BuildContext context, WidgetRef ref, Community selectedCommunity, bool isAnonymous) {
    if (commentController.text.isNotEmpty) {
      String title = commentController.text.trim();
      ref.read(postControllerProvider.notifier).shareTextPost(
        context: context,
        title: title,
        selectedCommunity: selectedCommunity,
        isAnonymous: isAnonymous,
        description: title,
        endsAt: DateTime.now()
      );
    } else {
      showSnackBar(context, 'Please enter a title');
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(userProvider)!;
        return Scaffold(
          endDrawer: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:100),
               const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Sub-Groups",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
        const Divider(), 
                Expanded(
                  child: ref.watch(communitiesChildrenProvider(widget.name)).when(
                        data: (communities) => ListView.builder(
                          itemCount: communities.length,
                          itemBuilder: (BuildContext context, int index) {
                            final community = communities[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              title: Text(community.id),
                              onTap: () {  
                                Routemaster.of(context).push('/${community.name}');
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                        error: (error, stackTrace) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ),
              ],
            ),
          ),
          body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
  expandedHeight: 125,
  floating: true,
  snap: true,
  backgroundColor: Colors.transparent,
  flexibleSpace: Stack(
    fit: StackFit.expand,
    children: [
      Positioned.fill(
        child: Image.network(
          community.banner,
          fit: BoxFit.cover,
        ),
      ),
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        left: 16,
        bottom: 16,
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(community.avatar),
              backgroundColor: Colors.grey[200],
              radius: 25,
            ),
            const SizedBox(width: 12),
            Text(
              community.id,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black45,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () => {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('New Session', style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
            const SizedBox(width: 10),
            community.mods.contains(user.uid)
                ? IconButton(
                    onPressed: () => navToTools(context),
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: "Moderator Tools",
                  )
                : OutlinedButton(
                    onPressed: () => joinDepartment(ref, community, context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: Text(
                      community.members.contains(user.uid) ? 'Joined' : 'Join',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
          ],
        ),
      ),
    ],
  ),
),

                ];
              },
              body: ref.watch(getCommunityPostsProvider(widget.name)).when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(
                          color: Color.fromARGB(68, 158, 158, 158),
                          thickness: 0.7,
                        ),
                        Spacer(),
                        Center(
                          child: Text(
                            "Nothing to show here",
                            style: TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
                          ),
                        ),
                        Spacer(),
                      ],
                    );
                  }
                  return ListView.builder(
  padding: const EdgeInsets.only(top: 15),
  itemCount: data.length,
  itemBuilder: (BuildContext context, int index) {
    final post = data[data.length - 1 - index];

                      
                      if (post.title == post.description) {
                        return Align(
                          alignment: post.username != user.name ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: post.username != user.name ? Colors.grey[300] : Colors.blue[300],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                                bottomLeft: post.username != user.name ? Radius.zero : const Radius.circular(10),
                                bottomRight: post.username != user.name ? const Radius.circular(10) : Radius.zero,
                              ),
                            ),
                           constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                                  minWidth: post.title!.length < 5 ? 50.0 + (post.title!.length * 5) : 0.0,
                              ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title!,
                                  style: const TextStyle(color: Colors.black, fontSize: 18),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      post.isAnonymous ? "Anonymous" : post.username,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),child:PostCard(post: post));
                      }
                    },
                  );

                },
                error: (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
          bottomNavigationBar: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ref.watch(getCommunityByNameProvider(widget.name)).when(
              data: (community) => Container(
                alignment: Alignment.center,
                height: 45,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(width: 0.5, color: Color.fromARGB(68, 158, 158, 158)))),
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 15),
                        controller: commentController,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(68, 158, 158, 158),
                          hintText: 'What are your thoughts?',
                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => sharePost(context, ref, community, false),
                        icon: const Icon(Icons.send, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
              error: (error, stackTrace) => const SizedBox(),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}