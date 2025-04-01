import "dart:io";
import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:resky/controller/community_controller.dart";
import "package:resky/controller/posts_controller.dart";
import "package:resky/core/utils.dart";
import "package:resky/models/community.dart";
import "package:resky/pages/comp/error_text.dart";
import "package:resky/pages/comp/loader.dart";

class AddPostTypes extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypes({super.key, required this.type});

  @override
  ConsumerState<AddPostTypes> createState() => _AddPostTypesState();
}

class _AddPostTypesState extends ConsumerState<AddPostTypes> {
  bool isAnonymous = false;
  File? bannerFile;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  /* void sharePost() {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            file: bannerFile,
            isAnonymous: isAnonymous,
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            description: descriptionController.text.trim(),
            isAnonymous: isAnonymous,
          );
    } else if (widget.type == 'link' &&
        linkController.text.isNotEmpty &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            link: linkController.text.trim(),
            isAnonymous: isAnonymous,
          );
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  } */

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';

    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text('Post ${widget.type}'),
          actions: [
            TextButton(
              onPressed: () => {},
              child: const Text(
                'Share',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Loader()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Enter Title here',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLength: 30,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    //image post

                    if (isTypeImage)
                      GestureDetector(
                        onTap: () => selectBannerImage(),
                        child: DottedBorder(
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          borderType: BorderType.RRect,
                          color: Colors.black,
                          child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: bannerFile != null
                                  ? Image.file(bannerFile!)
                                  : const Center(
                                      child: Icon(Icons.camera_alt))),
                        ),
                      ),

                    //text post

                    if (isTypeText)
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter Description here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        maxLines: 6,
                      ),

                    //link post

                    if (isTypeLink)
                      TextField(
                        controller: linkController,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter Link here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),

                    Row(
                      children: [
                        const Text('Anonymous:',style: TextStyle(fontSize: 17,)),
                        Switch.adaptive(
                            value: isAnonymous,
                            onChanged: (val) {
                              setState(() {
                                isAnonymous = val;
                              });
                            }),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ const Text('Select Department:',style: TextStyle(fontSize: 17,)),
                       ref.watch(userCommunitiesProvider).when(
                          data: (data) {
                            communities = data;

                            if (data.isEmpty) {
                              return const SizedBox();
                            }

                            return DropdownButton(
                                value: selectedCommunity ?? data[0],
                                items: data
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.id)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedCommunity = val;
                                  });
                                });
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        ),
                      ],
                    ),
                   
                  ],

                  //isAnonymous
                ),
              ));
  }
}
