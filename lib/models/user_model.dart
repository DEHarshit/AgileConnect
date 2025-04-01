class UserModel {
  final String name;
  final String propic;
  final String probanner;
  final String uid;
  final bool isAdmin;
  final String? role;
  final String? email;
  UserModel({
    required this.name,
    required this.propic,
    required this.probanner,
    required this.uid,
    required this.isAdmin,
    this.role,
    this.email,
  });

  UserModel copyWith({
    String? name,
    String? propic,
    String? probanner,
    String? uid,
    bool? isAdmin,
    String? email,
    String? role,
  }) {
    return UserModel(
      name: name ?? this.name,
      propic: propic ?? this.propic,
      probanner: probanner ?? this.probanner,
      uid: uid ?? this.uid,
      isAdmin: isAdmin ?? this.isAdmin,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'propic': propic,
      'probanner': probanner,
      'uid': uid,
      'isAdmin': isAdmin,
      'email': email,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      propic: map['propic'] ?? '',
      probanner: map['probanner'] ?? '',
      uid: map['uid'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, propic: $propic, probanner: $probanner, uid: $uid, isAdmin: $isAdmin, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.name == name &&
        other.propic == propic &&
        other.probanner == probanner &&
        other.uid == uid &&
        other.isAdmin == isAdmin &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        propic.hashCode ^
        probanner.hashCode ^
        uid.hashCode ^
        isAdmin.hashCode ^
        email.hashCode ^
        role.hashCode;
  }
}