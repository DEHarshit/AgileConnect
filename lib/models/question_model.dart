import 'package:flutter/foundation.dart';

class Question {
  final String id;
  final String title;
  final String link;
  final String communityName;
  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String username;
  final String uid;
  final String type; // subject
  final String date;
  final DateTime createdAt;
  Question({
    required this.id,
    required this.title,
    required this.link,
    required this.date,
    required this.communityName,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.username,
    required this.uid,
    required this.type,
    required this.createdAt,
  });

  Question copyWith({
    String? id,
    String? title,
    String? link,
    String? date,
    String? communityName,
    List<String>? upvotes,
    List<String>? downvotes,
    int? commentCount,
    String? username,
    String? uid,
    String? type,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      date: date ?? this.date,
      communityName: communityName ?? this.communityName,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'link': link,
      'date': date,
      'communityName': communityName,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'username': username,
      'uid': uid,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      date: map['date'],
      communityName: map['communityName'] ?? '',
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
  @override
  String toString() {
    return 'Question(id: $id, title: $title, link: $link, date: $date, communityName: $communityName, upvotes: $upvotes, downvotes: $downvotes, commentCount: $commentCount, username: $username, uid: $uid, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant Question other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.link == link &&
      other.date == date &&
      other.communityName == communityName &&
      listEquals(other.upvotes, upvotes) &&
      listEquals(other.downvotes, downvotes) &&
      other.commentCount == commentCount &&
      other.username == username &&
      other.uid == uid &&
      other.type == type &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      link.hashCode ^
      date.hashCode ^
      communityName.hashCode ^
      upvotes.hashCode ^
      downvotes.hashCode ^
      commentCount.hashCode ^
      username.hashCode ^
      uid.hashCode ^
      type.hashCode ^
      createdAt.hashCode;
  }
}
