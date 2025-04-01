import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/auth_controller.dart';
import 'package:resky/core/providers/storage_providers.dart';
import 'package:resky/core/utils.dart';
import 'package:resky/models/comment_model.dart';
import 'package:resky/models/community.dart';
import 'package:resky/models/post_model.dart';
import 'package:resky/services/posts_repository.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

final getCommentByIdProvider = StreamProvider.family((ref, String commentId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getCommentsById(commentId);
});

final getCommentRepliesProvider =
    StreamProvider.family((ref, String commentId) {
  final commentController = ref.watch(postControllerProvider.notifier);
  return commentController.fetchCommentReplies(commentId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //text

void shareTextPost({
  required BuildContext context,
  required String title,
  required Community selectedCommunity,
  required String description,
  required bool isAnonymous,
  required DateTime? endsAt,
}) async {
  state = true;
  String postId = const Uuid().v1();
  final user = _ref.read(userProvider)!;
  String? prevManSummary;

  try {
    final latestPostSnapshot =
        await _postRepository.getLatestPost(selectedCommunity.name);

    if (latestPostSnapshot != null) {
      final data = latestPostSnapshot.data() as Map<String, dynamic>;

      // Check if 'manualSummary' exists before accessing it
      if (data.containsKey('manualSummary')) {
        prevManSummary = data['manualSummary'] as String?;
      }
    }
  } catch (e) {
    debugPrint('Error fetching latest post: $e');
  }

  final Post post = Post(
    id: postId,
    title: title,
    communityName: selectedCommunity.name,
    communityId: selectedCommunity.id,
    communityProfile: selectedCommunity.avatar,
    upvotes: [],
    downvotes: [],
    sessionParticipants: [],
    commentCount: 0,
    username: user.name,
    uid: user.uid,
    type: 'text',
    isAnonymous: isAnonymous,
    createdAt: DateTime.now(),
    description: description,
    endsAt: endsAt,
    prevManSummary: prevManSummary
  );

  final res = await _postRepository.addPost(post);
  state = false;

  res.fold(
    (l) => showSnackBar(context, l.message),
    (r) => showSnackBar(context, 'Posted successfully!'),
  );
}

  //link
/*
  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
    required bool isAnonymous,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityId: selectedCommunity.id,
        communityProfile: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'link',
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        link: link);
    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  //Image

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
    required bool isAnonymous,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
    );

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityId: selectedCommunity.id,
          communityProfile: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: 'image',
          isAnonymous: isAnonymous,
          createdAt: DateTime.now(),
          link: r);
      final res = await _postRepository.addPost(post);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully!');
        Routemaster.of(context).pop();
      });
    });
  } */

 void sharePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String? description,
    required File? file,
    required bool isAnonymous,
    required DateTime? endsAt,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
      path: 'posts',
      id: postId,
      file: file,
    );

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
          id: postId,
          title: description,
          communityName: selectedCommunity.name,
          communityId: selectedCommunity.id,
          communityProfile: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          sessionParticipants: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: 'image',
          isAnonymous: isAnonymous,
          createdAt: DateTime.now(),
          link: r,
          endsAt: endsAt,
        description: title
      );
      final res = await _postRepository.addPost(post);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).push('/post/$postId/comments');
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Post deleted successfully!'));
  }

  void deleteComment(Comment comment, BuildContext context) async {
    final res = await _postRepository.deleteComment(comment);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Comment deleted successfully!'));
  }

  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  void upvoteComm(Comment comment) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvoteComm(comment, uid);
  }

  void downvoteComm(Comment comment) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvoteComm(comment, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }
  

  Stream<Comment> getCommentsById(String commentId) {
    return _postRepository.getCommentsById(commentId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
    required String type,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: user.name,
      profilePic: user.propic,
      type: type,
      uid: user.uid,
      upvotes: [],
      downvotes: [],
      actualPost: post.id,
      role: user.role.toString(),
    );
    final res = await _postRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Future<String> getActualPostId(String commentId) async {
    Comment commentSnapshot = await _postRepository.getCommentsById(commentId).first;
    String actualPostId= commentSnapshot.actualPost;
    return actualPostId;
  }

  void updatePostSummary({required String postId, required String manualSummary}) {
    _postRepository.updatePost(postId, {'manualSummary': manualSummary});
}


  void addReply({
    required BuildContext context,
    required String text,
    required Comment post,
    required String type,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    String actualPostId = await getActualPostId(post.id);
    Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user.name,
        profilePic: user.propic,
        type: type,
        uid: user.uid,
        upvotes: [],
        downvotes: [],
        actualPost: actualPostId,
        role: user.role.toString(),
        );
    final res = await _postRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  Stream<List<Comment>> fetchCommentReplies(String commentId) {
    return _postRepository.getRepliesOfComment(commentId);
  }
}