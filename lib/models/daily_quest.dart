import 'fish_species.dart';

class DailyQuest {
  final String id;
  final List<FishSpecies> targetFish;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> caughtFishIds;
  final bool isCompleted;

  const DailyQuest({
    required this.id,
    required this.targetFish,
    required this.createdAt,
    required this.expiresAt,
    this.caughtFishIds = const [],
    this.isCompleted = false,
  });

  int get progress => caughtFishIds.length;
  int get total => targetFish.length;
  double get progressPercentage => (progress / total * 100);

  bool isFishCaught(String fishId) {
    return caughtFishIds.contains(fishId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetFish': targetFish.map((f) => f.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'caughtFishIds': caughtFishIds,
      'isCompleted': isCompleted,
    };
  }

  factory DailyQuest.fromJson(Map<String, dynamic> json) {
    return DailyQuest(
      id: json['id'],
      targetFish: (json['targetFish'] as List)
          .map((f) => FishSpecies.fromJson(f))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      caughtFishIds: List<String>.from(json['caughtFishIds'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  DailyQuest copyWith({
    String? id,
    List<FishSpecies>? targetFish,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? caughtFishIds,
    bool? isCompleted,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      targetFish: targetFish ?? this.targetFish,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      caughtFishIds: caughtFishIds ?? this.caughtFishIds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
