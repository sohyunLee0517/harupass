import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, subject }

class UserModel {
  final String uid;
  final UserRole role;
  final String? email;
  final String name;
  final DateTime createdAt;
  final List<String> subjectIds;
  final String? adminId;
  final String nickname;
  final String profileEmoji;

  const UserModel({
    required this.uid,
    required this.role,
    this.email,
    required this.name,
    required this.createdAt,
    this.subjectIds = const [],
    this.adminId,
    this.nickname = '',
    this.profileEmoji = '😊',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        role: UserRole.values.byName(json['role'] as String),
        email: json['email'] as String?,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        subjectIds: (json['subjectIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        adminId: json['adminId'] as String?,
        nickname: json['nickname'] as String? ?? '',
        profileEmoji: json['profileEmoji'] as String? ?? '😊',
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role.name,
        'email': email,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'subjectIds': subjectIds,
        'adminId': adminId,
        'nickname': nickname,
        'profileEmoji': profileEmoji,
      };

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'uid': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() => {
        ...toJson(),
        'createdAt': Timestamp.fromDate(createdAt),
      }..remove('uid');
}
