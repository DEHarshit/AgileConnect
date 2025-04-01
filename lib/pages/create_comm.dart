import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resky/controller/community_controller.dart';
import 'package:resky/models/community.dart';
import 'package:resky/pages/comp/loader.dart';
import "package:resky/pages/comp/error_text.dart";
import "package:resky/pages/comp/loader.dart";

class CreateCommunity extends ConsumerStatefulWidget {
  const CreateCommunity({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityState();
}

class _CreateCommunityState extends ConsumerState<ConsumerStatefulWidget> {
  final communityNameController = TextEditingController();
  List<Community> communities = [];
  Community? selectedCommunity = Community(id: 'root',name: 'root',banner: '',avatar: '',members: [],mods: [],parent: '',topParent: '',children: [],);
  String parent = "root";
  String topParent = "root";

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    ref.read(communityControllerProvider.notifier).createCommunity(
          communityNameController.text.trim(),
          selectedCommunity!,
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create a group'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Align(
                      alignment: Alignment.topLeft, child: Text('Group Name')),
                  const SizedBox(height: 10),

                  // text field

                  TextField(
                    /* inputFormatters: [
                  FilteringTextInputFormatter.deny(
                     RegExp(r'\s')),
                ], */

                    controller: communityNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a group name',
                      filled: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 50,
                  ),

                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: createCommunity,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        )),
                    child: const Text('Create Group',
                        style: TextStyle(
                          fontSize: 17,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Group:',
                          style: TextStyle(fontSize: 17)),
                      ref.watch(communitiesProvider).when(
                            data: (data) {
                              communities = data;
                              if (data.isEmpty) {
                                return const SizedBox();
                              }

                              final rootCommunity = Community(
                                id: 'root',
                                name: 'root',
                                banner: '',
                                avatar: '',
                                members: [],
                                mods: [],
                                parent: '',
                                topParent: '',
                                children: [],
                              );

                              final dropdownItems = [rootCommunity, ...data]
                                  .map((e) => DropdownMenuItem<Community>(
                                        value: e,
                                        child: Text(e.id),
                                      ))
                                  .toList();

                              return DropdownButton<Community>(
                                value: selectedCommunity ?? rootCommunity,
                                items: dropdownItems,
                                onChanged: (val) {
                                  setState(() {
                                    selectedCommunity = val;
                                    parent = val!.name;
                                    topParent = val!.topParent;
                                    print(parent);
                                    print(topParent);
                                  });
                                },
                              );
                            },
                            error: (error, stackTrace) =>
                                ErrorText(error: error.toString()),
                            loading: () => const Loader(),
                          ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
