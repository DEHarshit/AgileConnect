import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/posts_controller.dart';
import 'package:resky/models/post_model.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class PostImage extends ConsumerWidget {
  final String postId;

  const PostImage({
    super.key,
    required this.postId,
  });

  void navToComments(BuildContext context) {
    Routemaster.of(context).push('/post/$postId/comments');
  }

  Future<void> downloadImage(String url, BuildContext context) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final result = await ImageGallerySaver.saveImage(
        response.data,
        quality: 100,
        name: 'image_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image to gallery')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsyncValue = ref.watch(getPostByIdProvider(postId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('View Image'),
        actions: [
                PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'download') {
      postAsyncValue.whenData((post) {
        if (post.link != null) {
          downloadImage(post.link!, context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image URL not found')),
          );
        }
      });
    }
  },
  icon: Icon(Icons.more_vert, color: Colors.white), 
  color: Colors.black,
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'download',
      child: Text(
        'Download',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ],
),

        ],
      ),
      body: postAsyncValue.when(
        data: (post) {
          return Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.network(post.link!),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => navToComments(context),
                            icon: const Icon(
                              Icons.favorite,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${post.upvotes.length - post.downvotes.length == 0 ? '0' : post.upvotes.length - post.downvotes.length}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
