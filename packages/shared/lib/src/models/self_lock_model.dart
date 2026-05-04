import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'self_lock_model.g.dart';

enum SelfLockType { instant, scheduled }

enum SelfLockStatus { scheduled, active, completed, cancelled }

@JsonSerializable()
class SelfLockModel {
  final String id;
  final SelfLockType type;
  final DateTime? scheduledStart;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final int plannedDuration; // minutes
  final int actualDuration; // minutes
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

  factory SelfLockModel.fromJson(Map<String, dynamic> json) =>
      _$SelfLockModelFromJson(json);
  Map<String, dynamic> toJson() => _$SelfLockModelToJson(this);

  factory SelfLockModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? parseTimestamp(dynamic val) =>
        val != null ? (val as Timestamp).toDate() : null;
    return SelfLockModel.fromJson({
      'id': doc.id,
      ...data,
      if (data['scheduledStart'] != null)
        'scheduledStart': parseTimestamp(data['scheduledStart'])!.toIso8601String(),
      if (data['actualStart'] != null)
        'actualStart': parseTimestamp(data['actualStart'])!.toIso8601String(),
      if (data['actualEnd'] != null)
        'actualEnd': parseTimestamp(data['actualEnd'])!.toIso8601String(),
      'createdAt': parseTimestamp(data['createdAt'])!.toIso8601String(),
    });
  }

  /// Calculate points: 1 point per 30-minute block
  static int calculatePoints(int durationMinutes) {
    return durationMinutes ~/ 30;
  }
}
