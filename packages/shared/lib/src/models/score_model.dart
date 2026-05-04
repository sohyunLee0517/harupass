import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'score_model.g.dart';

@JsonSerializable()
class ScoreModel {
  // Cumulative (permanent)
  final int totalStamps;
  final int bonusPoints;
  final int selfLockPoints;
  final int totalScore;
  final int currentStreak;
  final int maxStreak;
  final String? lastCompletedDate;
  final List<int> achievedMilestones;

  // Weekly (reset every Monday)
  final int weeklyStamps;
  final int weeklyBonus;
  final int weeklySelfLockPoints;
  final int weeklyScore;

  // League
  final String currentLeague;
  final String? currentGroupId;
  final String? bestLeague;

  const ScoreModel({
    this.totalStamps = 0,
    this.bonusPoints = 0,
    this.selfLockPoints = 0,
    this.totalScore = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastCompletedDate,
    this.achievedMilestones = const [],
    this.weeklyStamps = 0,
    this.weeklyBonus = 0,
    this.weeklySelfLockPoints = 0,
    this.weeklyScore = 0,
    this.currentLeague = 'dawn',
    this.currentGroupId,
    this.bestLeague,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreModelToJson(this);

  factory ScoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScoreModel.fromJson(data);
  }
}
