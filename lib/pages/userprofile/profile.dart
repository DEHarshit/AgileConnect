import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/auth_controller.dart';
import 'package:resky/controller/user_controller.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import 'package:resky/pages/comp/post_card.dart';

class UserProfile extends ConsumerWidget {
  final String uid;

  const UserProfile({
    super.key,
    required this.uid,
  });

  void navToEditUser(BuildContext context) {
    Routemaster.of(context).push('/user/$uid/edit');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewer = ref.read(userProvider);

    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    backgroundColor: const Color.fromARGB(68, 158, 158, 158),
                    flexibleSpace: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            user.probanner,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 20,
                          child: viewer?.name == user.name
                              ? ElevatedButton.icon(
                                  onPressed: () => navToEditUser(context),
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit Profile"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        Positioned(
                          bottom: -45,
                          left: 20,
                          right: 0,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.propic),
                                backgroundColor: const Color.fromARGB(68, 158, 158, 158),
                                radius: 45,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, left: 20),
                      child: Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          user.isAdmin == true
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green
                                        .shade100, 
                                    borderRadius: BorderRadius.circular(
                                        20), 
                                    border: Border.all(
                                        color: Colors.green,
                                        width: 2), 
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Admin",
                                        style: TextStyle(
                                          color: Colors.green, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                ];
              },
              body: ref.watch(getUserPostsProvider(uid)).when(
                    data: (data) => ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final post = data[index];
                        return viewer?.uid == post.uid
                            ? PostCard(post: post)
                            : post.isAnonymous
                                ? const SizedBox.shrink()
                                : PostCard(post: post);
                      },
                    ),
                    error: (error, stackTrace) =>
                        ErrorText(error: error.toString()),
                    loading: () => const Loader(),
                  ),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
