import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_state_model.g.dart';

enum StampType { normal, milestone }

@JsonSerializable()
class DailyStateModel {
  final bool allCompleted;
  final DateTime? lockReleasedAt;
  final StampType? stampType;

  const DailyStateModel({
    this.allCompleted = false,
    this.lockReleasedAt,
    this.stampType,
  });

  factory DailyStateModel.fromJson(Map<String, dynamic> json) =>
      _$DailyStateModelFromJson(json);
  Map<String, dynamic> toJson() => _$DailyStateModelToJson(this);

  factory DailyStateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyStateModel.fromJson({
      ...data,
      if (data['lockReleasedAt'] != null)
        'lockReleasedAt':
            (data['lockReleasedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}
