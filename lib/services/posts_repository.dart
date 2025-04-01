import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:resky/core/constants/firebase_constants.dart';
import 'package:resky/core/failure.dart';
import 'package:resky/core/providers/firebase_providers.dart';
import 'package:resky/core/type_defs.dart';
import 'package:resky/models/comment_model.dart';
import 'package:resky/models/community.dart';
import 'package:resky/models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteComment(Comment post) async {
    try {
      return right(_comments.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


  void upvote(Post post, String uid) async {
    if (post.downvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (post.upvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  void upvoteComm(Comment comment, String uid) async {
    if (comment.downvotes.contains(uid)) {
      _comments.doc(comment.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (comment.upvotes.contains(uid)) {
      _comments.doc(comment.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _comments.doc(comment.id).update({
        'upvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  void downvote(Post post, String uid) async {
    if (post.upvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (post.downvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  void downvoteComm(Comment comment, String uid) async {
    if (comment.upvotes.contains(uid)) {
      _comments.doc(comment.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (comment.downvotes.contains(uid)) {
      _comments.doc(comment.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _comments.doc(comment.id).update({
        'downvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<Comment> getCommentsById(String commentId) {
    return _comments
        .doc(commentId)
        .snapshots()
        .map((event) => Comment.fromMap(event.data() as Map<String, dynamic>));
  }


  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_posts.doc(comment.actualPost).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // comments

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Comment>> getRepliesOfComment(String commentId) {
    return _comments
        .where('postId', isEqualTo: commentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

Future<DocumentSnapshot?> getLatestPost(String communityName) async {
  final querySnapshot = await _posts
      .where('communityName', isEqualTo: communityName)
      .orderBy('createdAt', descending: true)
      .limit(5) 
      .get();

  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    if (data['title'] != data['description']) {
      return doc;
    }
  }
  
  return null; 
}


  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('posts').doc(postId).update(data);
}

}
