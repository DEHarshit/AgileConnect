import 'package:flutter/foundation.dart';

class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String username;
  final String profilePic;
  final String type; // replying to a post, comment or another reply
  final String uid;
  final List<String> upvotes;
  final List<String> downvotes;
  final String actualPost;
  final String role;
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.username,
    required this.profilePic,
    required this.type,
    required this.uid,
    required this.upvotes,
    required this.downvotes,
    required this.actualPost,
    required this.role,
  });

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? username,
    String? profilePic,
    String? type,
    String? uid,
    List<String>? upvotes,
    List<String>? downvotes,
    String? actualPost,
    String? role,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      type: type ?? this.type,
      uid: uid ?? this.uid,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      actualPost: actualPost ?? this.actualPost,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'username': username,
      'profilePic': profilePic,
      'type': type,
      'uid': uid,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'actualPost': actualPost,
      'role': role,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      postId: map['postId'] ?? '',
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
      type: map['type'] ?? '',
      uid: map['uid'] ?? '',
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
      actualPost: map['actualPost'] ?? '',
      role: map['role'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, username: $username, profilePic: $profilePic, type: $type, uid: $uid, upvotes: $upvotes, downvotes: $downvotes, actualPost: $actualPost, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.type == type &&
        other.uid == uid &&
        listEquals(other.upvotes, upvotes) &&
        listEquals(other.downvotes, downvotes) &&
        other.actualPost == actualPost &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        postId.hashCode ^
        username.hashCode ^
        profilePic.hashCode ^
        type.hashCode ^
        uid.hashCode ^
        upvotes.hashCode ^
        downvotes.hashCode ^
        actualPost.hashCode ^
        role.hashCode;
  }
}
