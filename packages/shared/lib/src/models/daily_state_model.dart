import 'package:cloud_firestore/cloud_firestore.dart';

enum StampType { normal, milestone }

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
      DailyStateModel(
        allCompleted: json['allCompleted'] as bool? ?? false,
        lockReleasedAt: json['lockReleasedAt'] != null
            ? DateTime.parse(json['lockReleasedAt'] as String)
            : null,
        stampType: json['stampType'] != null
            ? StampType.values.byName(json['stampType'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'allCompleted': allCompleted,
        'lockReleasedAt': lockReleasedAt?.toIso8601String(),
        'stampType': stampType?.name,
      };

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
