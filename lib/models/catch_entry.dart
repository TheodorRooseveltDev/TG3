class CatchEntry {
  final String id;
  final String fishSpeciesId;
  final String fishName;
  final double? weight;
  final double? length;
  final String fishingMethod;
  final String? photoPath;
  final String? notes;
  final DateTime caughtAt;
  final bool isPersonalBest;
  final bool isTrophyCatch;

  const CatchEntry({
    required this.id,
    required this.fishSpeciesId,
    required this.fishName,
    this.weight,
    this.length,
    required this.fishingMethod,
    this.photoPath,
    this.notes,
    required this.caughtAt,
    this.isPersonalBest = false,
    this.isTrophyCatch = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fishSpeciesId': fishSpeciesId,
      'fishName': fishName,
      'weight': weight,
      'length': length,
      'fishingMethod': fishingMethod,
      'photoPath': photoPath,
      'notes': notes,
      'caughtAt': caughtAt.toIso8601String(),
      'isPersonalBest': isPersonalBest,
      'isTrophyCatch': isTrophyCatch,
    };
  }

  factory CatchEntry.fromJson(Map<String, dynamic> json) {
    return CatchEntry(
      id: json['id'],
      fishSpeciesId: json['fishSpeciesId'],
      fishName: json['fishName'],
      weight: json['weight']?.toDouble(),
      length: json['length']?.toDouble(),
      fishingMethod: json['fishingMethod'],
      photoPath: json['photoPath'],
      notes: json['notes'],
      caughtAt: DateTime.parse(json['caughtAt']),
      isPersonalBest: json['isPersonalBest'] ?? false,
      isTrophyCatch: json['isTrophyCatch'] ?? false,
    );
  }

  CatchEntry copyWith({
    String? id,
    String? fishSpeciesId,
    String? fishName,
    double? weight,
    double? length,
    String? fishingMethod,
    String? photoPath,
    String? notes,
    DateTime? caughtAt,
    bool? isPersonalBest,
    bool? isTrophyCatch,
  }) {
    return CatchEntry(
      id: id ?? this.id,
      fishSpeciesId: fishSpeciesId ?? this.fishSpeciesId,
      fishName: fishName ?? this.fishName,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      fishingMethod: fishingMethod ?? this.fishingMethod,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      caughtAt: caughtAt ?? this.caughtAt,
      isPersonalBest: isPersonalBest ?? this.isPersonalBest,
      isTrophyCatch: isTrophyCatch ?? this.isTrophyCatch,
    );
  }
}
