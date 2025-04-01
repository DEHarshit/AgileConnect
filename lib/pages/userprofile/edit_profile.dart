import "dart:io";
import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:resky/controller/auth_controller.dart";
import "package:resky/controller/user_controller.dart";
import "package:resky/core/constants/constants.dart";
import "package:resky/core/utils.dart";
import "package:resky/pages/comp/error_text.dart";
import "package:resky/pages/comp/loader.dart";

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? avatarFile;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

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

  void save() {
    ref.read(userProfileControllerProvider.notifier).editDepartment(
          avatarFile: avatarFile,
          bannerFile: bannerFile,
          context: context,
          name: nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Edit Profile'),

              //save

              actions: [
                TextButton(
                    onPressed: () => save(),
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
                                  : user.probanner.isEmpty ||
                                          user.probanner ==
                                              Constants.bannerDefault
                                      ? const Center(
                                          child: Icon(Icons.camera_alt))
                                      : Image.network(user.probanner),
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
                                        NetworkImage(user.propic),
                                    radius: 28,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Name',
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }
}
