import "dart:io";

import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:resky/controller/community_controller.dart";
import "package:resky/core/constants/constants.dart";
import "package:resky/core/utils.dart";
import "package:resky/models/community.dart";
import "package:resky/pages/comp/error_text.dart";
import "package:resky/pages/comp/loader.dart";

class EditDepartment extends ConsumerStatefulWidget {
  final String name;
  const EditDepartment({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<EditDepartment> createState() => _EditDepartmentState();
}

class _EditDepartmentState extends ConsumerState<EditDepartment> {
  File? bannerFile;
  File? avatarFile;

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectAvatar() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        avatarFile = File(res.files.first.path!);
      });
    }
  }
    void saveCommunity(Community department) {
      ref.read(communityControllerProvider.notifier).editDepartment(
            avatarFile: avatarFile,
            bannerFile: bannerFile,
            context: context,
            department: department,
          );
    }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (department) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Edit Department'),
              backgroundColor: Colors.black,
              //save

              actions: [
                TextButton(
                    onPressed: () => saveCommunity(department),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
            body: isLoading ? const Loader() : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
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
                                  : department.banner.isEmpty ||
                                          department.banner ==
                                              Constants.bannerDefault
                                      ? const Center(
                                          child: Icon(Icons.camera_alt))
                                      : Image.network(department.banner),
                            ),
                          ),
                        ),

                        //avatar

                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => selectAvatar(),
                            child: avatarFile != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(avatarFile!),
                                    radius: 28,
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(department.avatar),
                                    radius: 28,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }
}
