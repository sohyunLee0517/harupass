import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { admin, subject }

@JsonSerializable()
class UserModel {
  final String uid;
  final UserRole role;
  final String? email;
  final String name;
  final DateTime createdAt;
  final List<String> subjectIds; // admin only
  final String? adminId; // subject only
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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'uid': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() => {
        ...toJson(),
        'createdAt': Timestamp.fromDate(createdAt),
      }..remove('uid');
}
