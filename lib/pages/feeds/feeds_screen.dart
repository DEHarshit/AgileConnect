import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/community_controller.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import 'package:resky/models/community.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  void navToDepartment(BuildContext context, Community department) {
    Routemaster.of(context).push(department.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentName = "root";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ref.watch(communitiesChildrenProvider(parentName)).when(
                data: (communities) => ListView.builder(
                  itemCount: communities.length,
                  itemBuilder: (BuildContext context, int index) {
                    final community = communities[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade300, width: 1),
                          right: BorderSide(color: Colors.grey.shade300, width: 1),
                          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        color: Colors.white, 
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8), 
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(community.avatar),
                          backgroundColor:
                              const Color.fromARGB(68, 158, 158, 158),
                        ),
                        title: Text(
                          community.id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => navToDepartment(context, community),
                      ),
                    );
                  },
                ),
                error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
        ),
      ],
    );
  }
}
