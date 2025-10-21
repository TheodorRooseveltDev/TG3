class FishSpecies {
  final String id;
  final String name;
  final String scientificName;
  final String type; // 'freshwater' or 'saltwater'
  final String rarity; // 'common', 'uncommon', 'rare', 'legendary'
  final String habitat;
  final List<String> bestBaits;
  final String depthRange;
  final String season;
  final int difficultyRating; // 1-5
  final String description;
  final String imageAsset;

  const FishSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.type,
    required this.rarity,
    required this.habitat,
    required this.bestBaits,
    required this.depthRange,
    required this.season,
    required this.difficultyRating,
    required this.description,
    required this.imageAsset,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'type': type,
      'rarity': rarity,
      'habitat': habitat,
      'bestBaits': bestBaits,
      'depthRange': depthRange,
      'season': season,
      'difficultyRating': difficultyRating,
      'description': description,
      'imageAsset': imageAsset,
    };
  }

  factory FishSpecies.fromJson(Map<String, dynamic> json) {
    return FishSpecies(
      id: json['id'],
      name: json['name'],
      scientificName: json['scientificName'],
      type: json['type'],
      rarity: json['rarity'],
      habitat: json['habitat'],
      bestBaits: List<String>.from(json['bestBaits']),
      depthRange: json['depthRange'],
      season: json['season'],
      difficultyRating: json['difficultyRating'],
      description: json['description'],
      imageAsset: json['imageAsset'],
    );
  }
}
