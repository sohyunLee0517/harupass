import 'package:cloud_firestore/cloud_firestore.dart';

enum SelfLockType { instant, scheduled }

enum SelfLockStatus { scheduled, active, completed, cancelled }

class SelfLockModel {
  final String id;
  final SelfLockType type;
  final DateTime? scheduledStart;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final int plannedDuration;
  final int actualDuration;
  final SelfLockStatus status;
  final int earnedPoints;
  final DateTime createdAt;

  const SelfLockModel({
    required this.id,
    required this.type,
    this.scheduledStart,
    this.actualStart,
    this.actualEnd,
    required this.plannedDuration,
    this.actualDuration = 0,
    this.status = SelfLockStatus.scheduled,
    this.earnedPoints = 0,
    required this.createdAt,
  });

  factory SelfLockModel.fromJson(Map<String, dynamic> json) => SelfLockModel(
        id: json['id'] as String,
        type: SelfLockType.values.byName(json['type'] as String),
        scheduledStart: json['scheduledStart'] != null
            ? DateTime.parse(json['scheduledStart'] as String)
            : null,
        actualStart: json['actualStart'] != null
            ? DateTime.parse(json['actualStart'] as String)
            : null,
        actualEnd: json['actualEnd'] != null
            ? DateTime.parse(json['actualEnd'] as String)
            : null,
        plannedDuration: json['plannedDuration'] as int,
        actualDuration: json['actualDuration'] as int? ?? 0,
        status: SelfLockStatus.values
            .byName(json['status'] as String? ?? 'scheduled'),
        earnedPoints: json['earnedPoints'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'scheduledStart': scheduledStart?.toIso8601String(),
        'actualStart': actualStart?.toIso8601String(),
        'actualEnd': actualEnd?.toIso8601String(),
        'plannedDuration': plannedDuration,
        'actualDuration': actualDuration,
        'status': status.name,
        'earnedPoints': earnedPoints,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SelfLockModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? parseTs(dynamic val) =>
        val != null ? (val as Timestamp).toDate() : null;
    return SelfLockModel.fromJson({
      'id': doc.id,
      ...data,
      if (data['scheduledStart'] != null)
        'scheduledStart': parseTs(data['scheduledStart'])!.toIso8601String(),
      if (data['actualStart'] != null)
        'actualStart': parseTs(data['actualStart'])!.toIso8601String(),
      if (data['actualEnd'] != null)
        'actualEnd': parseTs(data['actualEnd'])!.toIso8601String(),
      'createdAt': parseTs(data['createdAt'])!.toIso8601String(),
    });
  }

  static int calculatePoints(int durationMinutes) => durationMinutes ~/ 30;
}
