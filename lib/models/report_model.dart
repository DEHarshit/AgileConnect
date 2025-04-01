import 'package:flutter/foundation.dart';

class Report {
  final String id;
  final List<String> text;
  final DateTime createdAt;
  final String postId; // can be comment or post
  final String type; // report of post, comment
  final String communityName;
  final int reportCount;
  Report({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.type,
    required this.communityName,
    required this.reportCount,
  });

  Report copyWith({
    String? id,
    List<String>? text,
    DateTime? createdAt,
    String? postId,
    String? type,
    String? communityName,
    int? reportCount,
  }) {
    return Report(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      type: type ?? this.type,
      communityName: communityName ?? this.communityName,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'type': type,
      'communityName' : communityName,
      'reportCount' : reportCount,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      text: List<String>.from(map['text']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      postId: map['postId'] ?? '',
      type: map['type'] ?? '',
      communityName: map['communityName'] ?? '',
      reportCount: map['reportCount'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Report(id: $id, text: $text, createdAt: $createdAt, postId: $postId, type: $type, communityName : $communityName, reportCount: $reportCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Report &&
        other.id == id &&
        listEquals(other.text, text) &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.type == type  &&
        other.communityName == communityName &&
        other.reportCount == reportCount; //reminder check
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        postId.hashCode ^
        type.hashCode ^
        communityName.hashCode ^
        reportCount.hashCode;
  }
}
