class CatchEntry {
  final String id;
  final String fishSpeciesId;
  final String fishName;
  final double? weight;
  final double? length;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String fishingMethod;
  final String? photoPath;
  final String? notes;
  final String? weatherConditions;
  final DateTime caughtAt;
  final bool isPersonalBest;
  final bool isTrophyCatch;

  const CatchEntry({
    required this.id,
    required this.fishSpeciesId,
    required this.fishName,
    this.weight,
    this.length,
    this.location,
    this.latitude,
    this.longitude,
    required this.fishingMethod,
    this.photoPath,
    this.notes,
    this.weatherConditions,
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
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'fishingMethod': fishingMethod,
      'photoPath': photoPath,
      'notes': notes,
      'weatherConditions': weatherConditions,
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
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      fishingMethod: json['fishingMethod'],
      photoPath: json['photoPath'],
      notes: json['notes'],
      weatherConditions: json['weatherConditions'],
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
    String? location,
    double? latitude,
    double? longitude,
    String? fishingMethod,
    String? photoPath,
    String? notes,
    String? weatherConditions,
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
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fishingMethod: fishingMethod ?? this.fishingMethod,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      caughtAt: caughtAt ?? this.caughtAt,
      isPersonalBest: isPersonalBest ?? this.isPersonalBest,
      isTrophyCatch: isTrophyCatch ?? this.isTrophyCatch,
    );
  }
}
