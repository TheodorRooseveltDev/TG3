class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredCount;
  final String category; // 'catches', 'streaks', 'collection', 'quests'
  final bool isUnlocked;
  final int currentProgress;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.category,
    this.isUnlocked = false,
    this.currentProgress = 0,
    this.unlockedAt,
  });

  double get progressPercentage {
    if (requiredCount == 0) return 100.0;
    return (currentProgress / requiredCount * 100).clamp(0.0, 100.0);
  }

  // Calculate token reward based on category and difficulty
  int get tokenReward {
    switch (category) {
      case 'catches':
        if (requiredCount >= 100) return 10; // Master
        if (requiredCount >= 50) return 5;   // Advanced
        if (requiredCount >= 10) return 3;   // Intermediate
        return 1; // Beginner
      
      case 'streaks':
        if (requiredCount >= 100) return 15; // Legendary
        if (requiredCount >= 30) return 8;   // Monthly
        if (requiredCount >= 7) return 4;    // Weekly
        return 2;
      
      case 'collection':
        if (requiredCount >= 50) return 10;  // Master collector
        if (requiredCount >= 20) return 6;   // Advanced
        return 3;
      
      case 'quests':
        if (requiredCount >= 100) return 12;
        if (requiredCount >= 50) return 7;
        if (requiredCount >= 10) return 4;
        return 2;
      
      default:
        return 1;
    }
  }

  String get rewardDescription {
    return '$tokenReward Bait Token${tokenReward > 1 ? 's' : ''}';
  }

  String get difficultyTier {
    switch (category) {
      case 'catches':
        if (requiredCount >= 100) return 'MASTER';
        if (requiredCount >= 50) return 'ADVANCED';
        if (requiredCount >= 10) return 'INTERMEDIATE';
        return 'BEGINNER';
      
      case 'streaks':
        if (requiredCount >= 100) return 'LEGENDARY';
        if (requiredCount >= 30) return 'ADVANCED';
        if (requiredCount >= 7) return 'INTERMEDIATE';
        return 'BEGINNER';
      
      case 'collection':
        if (requiredCount >= 50) return 'MASTER';
        if (requiredCount >= 20) return 'ADVANCED';
        return 'INTERMEDIATE';
      
      case 'quests':
        if (requiredCount >= 100) return 'MASTER';
        if (requiredCount >= 50) return 'ADVANCED';
        if (requiredCount >= 10) return 'INTERMEDIATE';
        return 'BEGINNER';
      
      default:
        return 'STANDARD';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'requiredCount': requiredCount,
      'category': category,
      'isUnlocked': isUnlocked,
      'currentProgress': currentProgress,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      requiredCount: json['requiredCount'],
      category: json['category'],
      isUnlocked: json['isUnlocked'] ?? false,
      currentProgress: json['currentProgress'] ?? 0,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
    );
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? requiredCount,
    String? category,
    bool? isUnlocked,
    int? currentProgress,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredCount: requiredCount ?? this.requiredCount,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
