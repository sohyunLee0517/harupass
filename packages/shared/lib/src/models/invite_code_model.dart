import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invite_code_model.g.dart';

enum InviteCodeStatus { active, used, expired }

@JsonSerializable()
class InviteCodeModel {
  final String code;
  final String adminId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? usedBy;
  final InviteCodeStatus status;

  const InviteCodeModel({
    required this.code,
    required this.adminId,
    required this.createdAt,
    required this.expiresAt,
    this.usedBy,
    this.status = InviteCodeStatus.active,
  });

  factory InviteCodeModel.fromJson(Map<String, dynamic> json) =>
      _$InviteCodeModelFromJson(json);
  Map<String, dynamic> toJson() => _$InviteCodeModelToJson(this);

  factory InviteCodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteCodeModel.fromJson({
      'code': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'expiresAt': (data['expiresAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isUsable => status == InviteCodeStatus.active && !isExpired;
}
