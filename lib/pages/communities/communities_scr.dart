import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/community_controller.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import 'package:resky/models/community.dart';

class AllCommunity extends ConsumerWidget {
  const AllCommunity({super.key});

  void navToDepartment(BuildContext context, Community department) {
    Routemaster.of(context).push(department.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Discover Communities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ref.watch(communitiesProvider).when(
                data: (communities) => ListView.builder(
                        itemCount: communities.length,
                        itemBuilder: (BuildContext context, int index) {
                          final community = communities[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              backgroundColor: const Color.fromARGB(68, 158, 158, 158),
                            ),
                            title: Text(community.id),
                            onTap: () => navToDepartment(context, community),
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
