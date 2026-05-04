import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreModel {
  final int totalStamps;
  final int bonusPoints;
  final int selfLockPoints;
  final int totalScore;
  final int currentStreak;
  final int maxStreak;
  final String? lastCompletedDate;
  final List<int> achievedMilestones;
  final int weeklyStamps;
  final int weeklyBonus;
  final int weeklySelfLockPoints;
  final int weeklyScore;
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

  factory ScoreModel.fromJson(Map<String, dynamic> json) => ScoreModel(
        totalStamps: json['totalStamps'] as int? ?? 0,
        bonusPoints: json['bonusPoints'] as int? ?? 0,
        selfLockPoints: json['selfLockPoints'] as int? ?? 0,
        totalScore: json['totalScore'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        maxStreak: json['maxStreak'] as int? ?? 0,
        lastCompletedDate: json['lastCompletedDate'] as String?,
        achievedMilestones: (json['achievedMilestones'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
        weeklyStamps: json['weeklyStamps'] as int? ?? 0,
        weeklyBonus: json['weeklyBonus'] as int? ?? 0,
        weeklySelfLockPoints: json['weeklySelfLockPoints'] as int? ?? 0,
        weeklyScore: json['weeklyScore'] as int? ?? 0,
        currentLeague: json['currentLeague'] as String? ?? 'dawn',
        currentGroupId: json['currentGroupId'] as String?,
        bestLeague: json['bestLeague'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'totalStamps': totalStamps,
        'bonusPoints': bonusPoints,
        'selfLockPoints': selfLockPoints,
        'totalScore': totalScore,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'lastCompletedDate': lastCompletedDate,
        'achievedMilestones': achievedMilestones,
        'weeklyStamps': weeklyStamps,
        'weeklyBonus': weeklyBonus,
        'weeklySelfLockPoints': weeklySelfLockPoints,
        'weeklyScore': weeklyScore,
        'currentLeague': currentLeague,
        'currentGroupId': currentGroupId,
        'bestLeague': bestLeague,
      };

  factory ScoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScoreModel.fromJson(data);
  }
}
