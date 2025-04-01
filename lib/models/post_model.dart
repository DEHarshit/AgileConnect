import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String? title;
  final String? link;
  final String description;
  final String communityName;
  final String communityId;
  final String communityProfile;
  final List<String> upvotes;
  final List<String> downvotes;
  final List<String> sessionParticipants;  
  final int commentCount;
  final String username;
  final String uid;
  final String type;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? endsAt;
  final String? aiSummary;
  final String? manualSummary;
  final String? prevManSummary;

  Post({
    required this.id,
    this.title,
    this.link,
    required this.description,
    required this.communityName,
    required this.communityId,
    required this.communityProfile,
    required this.upvotes,
    required this.downvotes,
    required this.sessionParticipants, 
    required this.commentCount,
    required this.username,
    required this.uid,
    required this.type,
    required this.isAnonymous,
    required this.createdAt,
    this.endsAt,
    this.aiSummary,
    this.manualSummary,
    this.prevManSummary,
  });

  Post copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? communityName,
    String? communityId,
    String? communityProfile,
    List<String>? upvotes,
    List<String>? downvotes,
    List<String>? sessionParticipants, 
    int? commentCount,
    String? username,
    String? uid,
    String? type,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? endsAt,
    String? aiSummary,
    String? manualSummary,
    String? prevManSummary,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityId: communityId ?? this.communityId,
      communityProfile: communityProfile ?? this.communityProfile,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      sessionParticipants: sessionParticipants ?? this.sessionParticipants,  
      commentCount: commentCount ?? this.commentCount,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      endsAt: endsAt ?? this.endsAt,
      aiSummary: aiSummary ?? this.aiSummary,
      manualSummary: manualSummary ?? this.manualSummary,
      prevManSummary: prevManSummary ?? this.prevManSummary,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'link': link,
      'description': description,
      'communityName': communityName,
      'communityId': communityId,
      'communityProfile': communityProfile,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'sessionParticipants': sessionParticipants,  
      'commentCount': commentCount,
      'username': username,
      'uid': uid,
      'type': type,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'endsAt': endsAt?.millisecondsSinceEpoch,
      'aiSummary': aiSummary,
      'manualSummary': manualSummary,
      'prevManSummary': prevManSummary,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      title: map['title'],
      link: map['link'],
      description: map['description'] ?? '',
      communityName: map['communityName'] ?? '',
      communityId: map['communityId'] ?? '',
      communityProfile: map['communityProfile'] ?? '',
      upvotes: List<String>.from(map['upvotes'] ?? []),
      downvotes: List<String>.from(map['downvotes'] ?? []),
      sessionParticipants: List<String>.from(map['sessionParticipants'] ?? []),  
      commentCount: map['commentCount']?.toInt() ?? 0,
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      endsAt: map['endsAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endsAt']) : null,
      aiSummary: map['aiSummary'],
      manualSummary: map['manualSummary'],
      prevManSummary: map['prevManSummary'],
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, link: $link, description: $description, communityName: $communityName, communityId: $communityId, communityProfile: $communityProfile, upvotes: $upvotes, downvotes: $downvotes, sessionParticipants: $sessionParticipants, commentCount: $commentCount, username: $username, uid: $uid, type: $type, isAnonymous: $isAnonymous, createdAt: $createdAt, endsAt: $endsAt, aiSummary: $aiSummary, manualSummary: $manualSummary, prevManSummary: $prevManSummary)';
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return 
      other.id == id &&
      other.title == title &&
      other.link == link &&
      other.description == description &&
      other.communityName == communityName &&
      other.communityId == communityId &&
      other.communityProfile == communityProfile &&
      listEquals(other.upvotes, upvotes) &&
      listEquals(other.downvotes, downvotes) &&
      listEquals(other.sessionParticipants, sessionParticipants) && 
      other.commentCount == commentCount &&
      other.username == username &&
      other.uid == uid &&
      other.type == type &&
      other.isAnonymous == isAnonymous &&
      other.createdAt == createdAt &&
      other.endsAt == endsAt &&
      other.aiSummary == aiSummary &&
      other.manualSummary == manualSummary &&
      other.prevManSummary == prevManSummary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      link.hashCode ^
      description.hashCode ^
      communityName.hashCode ^
      communityId.hashCode ^
      communityProfile.hashCode ^
      upvotes.hashCode ^
      downvotes.hashCode ^
      sessionParticipants.hashCode ^ 
      commentCount.hashCode ^
      username.hashCode ^
      uid.hashCode ^
      type.hashCode ^
      isAnonymous.hashCode ^
      createdAt.hashCode ^
      endsAt.hashCode ^
      aiSummary.hashCode ^
      manualSummary.hashCode ^
      prevManSummary.hashCode;
  }
}