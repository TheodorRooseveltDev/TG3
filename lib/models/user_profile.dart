class UserProfile {
  final String name;
  final String experienceLevel; // 'beginner', 'intermediate', 'expert'
  final List<String> favoriteEnvironments; // 'lakes', 'rivers', 'sea', 'ponds'
  final String? avatarPath;
  final int dailyStreak;
  final int weeklyStreak;
  final int baitTokens;
  final int completedQuests;
  final List<String> unlockedFishIds; // Fish species unlocked with tokens
  final DateTime createdAt;
  final DateTime lastActive;

  const UserProfile({
    required this.name,
    required this.experienceLevel,
    required this.favoriteEnvironments,
    this.avatarPath,
    this.dailyStreak = 0,
    this.weeklyStreak = 0,
    this.baitTokens = 3,
    this.completedQuests = 0,
    this.unlockedFishIds = const [],
    required this.createdAt,
    required this.lastActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'experienceLevel': experienceLevel,
      'favoriteEnvironments': favoriteEnvironments,
      'avatarPath': avatarPath,
      'dailyStreak': dailyStreak,
      'weeklyStreak': weeklyStreak,
      'baitTokens': baitTokens,
      'completedQuests': completedQuests,
      'unlockedFishIds': unlockedFishIds,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      experienceLevel: json['experienceLevel'],
      favoriteEnvironments: List<String>.from(json['favoriteEnvironments']),
      avatarPath: json['avatarPath'],
      dailyStreak: json['dailyStreak'] ?? 0,
      weeklyStreak: json['weeklyStreak'] ?? 0,
      baitTokens: json['baitTokens'] ?? 3,
      completedQuests: json['completedQuests'] ?? 0,
      unlockedFishIds: json['unlockedFishIds'] != null 
          ? List<String>.from(json['unlockedFishIds']) 
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      lastActive: DateTime.parse(json['lastActive']),
    );
  }

  UserProfile copyWith({
    String? name,
    String? experienceLevel,
    List<String>? favoriteEnvironments,
    String? avatarPath,
    int? dailyStreak,
    int? weeklyStreak,
    int? baitTokens,
    int? completedQuests,
    List<String>? unlockedFishIds,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      name: name ?? this.name,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      favoriteEnvironments: favoriteEnvironments ?? this.favoriteEnvironments,
      avatarPath: avatarPath ?? this.avatarPath,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      baitTokens: baitTokens ?? this.baitTokens,
      completedQuests: completedQuests ?? this.completedQuests,
      unlockedFishIds: unlockedFishIds ?? this.unlockedFishIds,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  String get userInitial => name.isNotEmpty ? name[0].toUpperCase() : 'A';
}
