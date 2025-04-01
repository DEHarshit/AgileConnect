import 'package:flutter/foundation.dart';

class Community {
  final String id;
  final String name;
  final String banner;
  final String avatar;
  final List<String> members;
  final List<String> mods;
  final String parent;
  final String topParent;
  final List<String>? children;

  Community({
    required this.id,
    required this.name,
    required this.banner,
    required this.avatar,
    required this.members,
    required this.mods,
    required this.parent,
    required this.topParent,
    this.children,
  });

  Community copyWith({
    String? id,
    String? name,
    String? banner,
    String? avatar,
    List<String>? members,
    List<String>? mods,
    String? parent,
    String? topParent,
    List<String>? children,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      banner: banner ?? this.banner,
      avatar: avatar ?? this.avatar,
      members: members ?? this.members,
      mods: mods ?? this.mods,
      parent: parent ?? this.parent,
      topParent: topParent ?? this.topParent,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'banner': banner,
      'avatar': avatar,
      'members': members,
      'mods': mods,
      'parent': parent,
      'topParent': topParent,
      'children': children,
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      banner: map['banner'] ?? '',
      avatar: map['avatar'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      mods: List<String>.from(map['mods'] ?? []),
      parent: map['parent'] ?? '',
      topParent: map['topParent'] ?? '',
      children: List<String>.from(map['children'] ??[]),
    );
  }

  @override
  String toString() {
    return 'Community(id: $id, name: $name, banner: $banner, avatar: $avatar, members: $members, mods: $mods, parent: $parent, topParent: $topParent, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Community &&
        other.id == id &&
        other.name == name &&
        other.banner == banner &&
        other.avatar == avatar &&
        listEquals(other.members, members) &&
        listEquals(other.mods, mods) &&
        other.parent == parent &&
        other.topParent == topParent &&
        listEquals(other.children, children);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        banner.hashCode ^
        avatar.hashCode ^
        members.hashCode ^
        mods.hashCode ^
        parent.hashCode ^
        topParent.hashCode ^
        children.hashCode;
  }
}
