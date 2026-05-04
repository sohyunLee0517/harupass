class AppConstants {
  AppConstants._();

  // Invite Code
  static const int inviteCodeLength = 6;
  static const Duration inviteCodeExpiry = Duration(hours: 24);

  // Mission
  static const int maxDailyProposals = 3;

  // Self Lock
  static const int selfLockMinMinutes = 30;
  static const int selfLockMaxMinutes = 120;
  static const int selfLockStepMinutes = 30;
  static const int selfLockPointsPerStep = 1;

  // Score & Milestones
  static const List<int> milestoneDays = [3, 5, 7];
  static const Map<int, int> milestoneBonus = {
    3: 3,
    5: 5,
    7: 7,
  };

  // League
  static const int leagueGroupSize = 30;
  static const int leaguePromoteCount = 7;
  static const int leagueDemoteCount = 7;

  // League tiers (order matters)
  static const List<String> leagueTiers = [
    'dawn',
    'morning',
    'noon',
    'sunset',
    'star',
    'moon',
    'sun',
  ];

  static const Map<String, String> leagueNames = {
    'dawn': '새벽',
    'morning': '아침',
    'noon': '정오',
    'sunset': '노을',
    'star': '별',
    'moon': '달',
    'sun': '해',
  };
}
