import 'package:cloud_firestore/cloud_firestore.dart';

enum InviteCodeStatus { active, used, expired }

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
      InviteCodeModel(
        code: json['code'] as String,
        adminId: json['adminId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        usedBy: json['usedBy'] as String?,
        status: InviteCodeStatus.values
            .byName(json['status'] as String? ?? 'active'),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'adminId': adminId,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'usedBy': usedBy,
        'status': status.name,
      };

  factory InviteCodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteCodeModel.fromJson({
      'code': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'expiresAt':
          (data['expiresAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isUsable => status == InviteCodeStatus.active && !isExpired;
}
