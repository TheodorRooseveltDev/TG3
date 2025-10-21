class CompletedQuest {
  final String id;
  final List<String> targetFishIds;
  final List<String> targetFishNames;
  final DateTime completedAt;
  final int tokensEarned;
  final Duration completionTime;

  CompletedQuest({
    required this.id,
    required this.targetFishIds,
    required this.targetFishNames,
    required this.completedAt,
    this.tokensEarned = 2,
    required this.completionTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetFishIds': targetFishIds,
      'targetFishNames': targetFishNames,
      'completedAt': completedAt.toIso8601String(),
      'tokensEarned': tokensEarned,
      'completionTime': completionTime.inSeconds,
    };
  }

  factory CompletedQuest.fromJson(Map<String, dynamic> json) {
    return CompletedQuest(
      id: json['id'],
      targetFishIds: List<String>.from(json['targetFishIds']),
      targetFishNames: List<String>.from(json['targetFishNames']),
      completedAt: DateTime.parse(json['completedAt']),
      tokensEarned: json['tokensEarned'] ?? 2,
      completionTime: Duration(seconds: json['completionTime']),
    );
  }
}
