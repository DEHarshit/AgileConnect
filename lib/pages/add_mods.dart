import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resky/controller/auth_controller.dart';
import 'package:resky/controller/community_controller.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<AddModsScreen> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int counter = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref.read(communityControllerProvider.notifier).addMods(
          widget.name,
          uids.toList(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final mod = ref.watch(userProvider)!;
    return Scaffold(
        appBar: AppBar(
          //save button
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              onPressed: () => saveMods(),
              icon: const Icon(Icons.done),
            )
          ],
        ),
        body: ref.watch(getCommunityByNameProvider(widget.name)).when(
              data: (department) => ListView.builder(
                itemCount: department.members.length,
                itemBuilder: (BuildContext context, int index) {
                  final member = department.members[index];

                  return ref.watch(getUserDataProvider(member)).when(
                        data: (user) {
                          if (department.mods.contains(member) &&
                              counter <= department.mods.length) {
                            uids.add(member);
                          }
                          counter++;
                          return CheckboxListTile(
                            value: uids.contains(member),
                            onChanged: (val) {
                              if (val!) {
                                addUid(member);
                              } else {
                                if (mod.uid != member &&
                                    department.mods[0] != member) {
                                  removeUid(member);
                                }
                              }
                            },
                            title: Text(department.mods[0] == user.uid
                                ? '${user.name} (Admin)'
                                : mod.uid == user.uid
                                    ? '${user.name} (You)'
                                    : user.name),
                          );
                        },
                        error: (error, stackTrace) => ErrorText(
                          error: error.toString(),
                        ),
                        loading: () => const Loader(),
                      );
                },
              ),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ));
  }
}
