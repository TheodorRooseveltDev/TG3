import '../models/fish_species.dart';

class FishDatabase {
  static final List<FishSpecies> allFish = [
    // Freshwater - Common
    const FishSpecies(
      id: 'bluegill',
      name: 'Bluegill',
      scientificName: 'Lepomis macrochirus',
      type: 'freshwater',
      rarity: 'common',
      habitat: 'Found in ponds, lakes, and slow-moving streams with vegetation',
      bestBaits: ['Worms', 'Small jigs', 'Crickets'],
      depthRange: '2-12 feet',
      season: 'Spring through Fall',
      difficultyRating: 1,
      description: 'A popular panfish with distinctive blue coloring on the gill covers. Great for beginners!',
      imageAsset: 'assets/images/bluegill.png',
    ),
    const FishSpecies(
      id: 'crappie',
      name: 'Crappie',
      scientificName: 'Pomoxis',
      type: 'freshwater',
      rarity: 'common',
      habitat: 'Lakes and reservoirs with brush piles and submerged structures',
      bestBaits: ['Minnows', 'Small jigs', 'Spinners'],
      depthRange: '8-20 feet',
      season: 'Year-round, best in Spring',
      difficultyRating: 2,
      description: 'Excellent eating fish that school together. Look for them near structure.',
      imageAsset: 'assets/images/crappie.png',
    ),
    const FishSpecies(
      id: 'yellow_perch',
      name: 'Yellow Perch',
      scientificName: 'Perca flavescens',
      type: 'freshwater',
      rarity: 'common',
      habitat: 'Cool lakes and ponds with sandy or rocky bottoms',
      bestBaits: ['Minnows', 'Worms', 'Small lures'],
      depthRange: '10-30 feet',
      season: 'Year-round',
      difficultyRating: 2,
      description: 'Distinctive yellow body with vertical stripes. Often found in schools.',
      imageAsset: 'assets/images/yellow_perch.png',
    ),

    // Freshwater - Uncommon
    const FishSpecies(
      id: 'largemouth_bass',
      name: 'Largemouth Bass',
      scientificName: 'Micropterus salmoides',
      type: 'freshwater',
      rarity: 'uncommon',
      habitat: 'Lakes, ponds, and rivers with plenty of cover like weeds and logs',
      bestBaits: ['Plastic worms', 'Crankbaits', 'Topwater lures'],
      depthRange: '5-20 feet',
      season: 'Spring through Fall',
      difficultyRating: 3,
      description: 'The most popular game fish in North America. Aggressive and fun to catch!',
      imageAsset: 'assets/images/largemouth_bass.png',
    ),
    const FishSpecies(
      id: 'rainbow_trout',
      name: 'Rainbow Trout',
      scientificName: 'Oncorhynchus mykiss',
      type: 'freshwater',
      rarity: 'uncommon',
      habitat: 'Cold, clear streams and mountain lakes',
      bestBaits: ['Flies', 'Salmon eggs', 'Small spinners'],
      depthRange: '3-15 feet',
      season: 'Spring and Fall',
      difficultyRating: 3,
      description: 'Beautiful fish with pink stripe. Prefers cold, oxygen-rich water.',
      imageAsset: 'assets/images/rainbow_trout.png',
    ),
    const FishSpecies(
      id: 'walleye',
      name: 'Walleye',
      scientificName: 'Sander vitreus',
      type: 'freshwater',
      rarity: 'uncommon',
      habitat: 'Large lakes and rivers with rocky or gravel bottoms',
      bestBaits: ['Live bait', 'Jigs', 'Crankbaits'],
      depthRange: '10-40 feet',
      season: 'Spring and Fall, also active at night',
      difficultyRating: 3,
      description: 'Prized for their excellent taste. Most active in low light conditions.',
      imageAsset: 'assets/images/walleye.png',
    ),
    const FishSpecies(
      id: 'catfish',
      name: 'Channel Catfish',
      scientificName: 'Ictalurus punctatus',
      type: 'freshwater',
      rarity: 'uncommon',
      habitat: 'Rivers, lakes, and ponds with muddy or sandy bottoms',
      bestBaits: ['Cut bait', 'Stink bait', 'Worms'],
      depthRange: 'Bottom feeders, 5-30 feet',
      season: 'Year-round, best in Summer',
      difficultyRating: 2,
      description: 'Strong fighters with excellent sense of smell. Often caught at night.',
      imageAsset: 'assets/images/catfish.png',
    ),

    // Freshwater - Rare
    const FishSpecies(
      id: 'northern_pike',
      name: 'Northern Pike',
      scientificName: 'Esox lucius',
      type: 'freshwater',
      rarity: 'rare',
      habitat: 'Weedy lakes and slow rivers in cool climates',
      bestBaits: ['Large spoons', 'Spinnerbaits', 'Live bait'],
      depthRange: '5-25 feet',
      season: 'Spring and Fall',
      difficultyRating: 4,
      description: 'Aggressive predator with sharp teeth. Can grow to impressive sizes!',
      imageAsset: 'assets/images/northern_pike.png',
    ),
    const FishSpecies(
      id: 'muskellunge',
      name: 'Muskellunge',
      scientificName: 'Esox masquinongy',
      type: 'freshwater',
      rarity: 'rare',
      habitat: 'Large, clear lakes and rivers with vegetation',
      bestBaits: ['Large lures', 'Bucktails', 'Jerkbaits'],
      depthRange: '15-40 feet',
      season: 'Fall',
      difficultyRating: 5,
      description: 'The "fish of 10,000 casts". Trophy predator that requires patience.',
      imageAsset: 'assets/images/muskellunge.png',
    ),
    const FishSpecies(
      id: 'brook_trout',
      name: 'Brook Trout',
      scientificName: 'Salvelinus fontinalis',
      type: 'freshwater',
      rarity: 'rare',
      habitat: 'Cold, pristine streams and mountain lakes',
      bestBaits: ['Flies', 'Small spinners', 'Worms'],
      depthRange: '2-10 feet',
      season: 'Spring and Fall',
      difficultyRating: 4,
      description: 'Beautiful native trout with red spots. Indicator of pristine water.',
      imageAsset: 'assets/images/brook_trout.png',
    ),

    // Saltwater - Common
    const FishSpecies(
      id: 'striped_mullet',
      name: 'Striped Mullet',
      scientificName: 'Mugil cephalus',
      type: 'saltwater',
      rarity: 'common',
      habitat: 'Coastal waters, bays, and estuaries',
      bestBaits: ['Bread', 'Dough balls', 'Small hooks'],
      depthRange: 'Surface to 10 feet',
      season: 'Year-round',
      difficultyRating: 1,
      description: 'Fast-swimming schooling fish found near the surface.',
      imageAsset: 'assets/images/striped_mullet.png',
    ),
    const FishSpecies(
      id: 'sand_perch',
      name: 'Sand Perch',
      scientificName: 'Diplectrum formosum',
      type: 'saltwater',
      rarity: 'common',
      habitat: 'Sandy bottoms in shallow coastal waters',
      bestBaits: ['Shrimp', 'Cut bait', 'Small jigs'],
      depthRange: '10-50 feet',
      season: 'Year-round',
      difficultyRating: 1,
      description: 'Small but tasty fish commonly caught from piers and boats.',
      imageAsset: 'assets/images/sand_perch.png',
    ),

    // Saltwater - Uncommon
    const FishSpecies(
      id: 'redfish',
      name: 'Red Drum (Redfish)',
      scientificName: 'Sciaenops ocellatus',
      type: 'saltwater',
      rarity: 'uncommon',
      habitat: 'Shallow coastal waters, grass flats, and marshes',
      bestBaits: ['Shrimp', 'Crabs', 'Soft plastics'],
      depthRange: '2-15 feet',
      season: 'Year-round, best in Fall',
      difficultyRating: 3,
      description: 'Copper-colored fish with distinctive spot on tail. Strong fighters!',
      imageAsset: 'assets/images/redfish.png',
    ),
    const FishSpecies(
      id: 'snook',
      name: 'Common Snook',
      scientificName: 'Centropomus undecimalis',
      type: 'saltwater',
      rarity: 'uncommon',
      habitat: 'Mangroves, bridges, and coastal structures',
      bestBaits: ['Live bait', 'Plugs', 'Soft plastics'],
      depthRange: '3-20 feet',
      season: 'Summer and Fall',
      difficultyRating: 4,
      description: 'Excellent game fish with a distinctive black lateral line.',
      imageAsset: 'assets/images/snook.png',
    ),
    const FishSpecies(
      id: 'flounder',
      name: 'Summer Flounder',
      scientificName: 'Paralichthys dentatus',
      type: 'saltwater',
      rarity: 'uncommon',
      habitat: 'Sandy or muddy bottoms near coastal areas',
      bestBaits: ['Live minnows', 'Squid', 'Bucktails'],
      depthRange: '10-60 feet',
      season: 'Spring through Fall',
      difficultyRating: 3,
      description: 'Flatfish that lies on the bottom. Excellent table fare.',
      imageAsset: 'assets/images/flounder.png',
    ),

    // Saltwater - Rare
    const FishSpecies(
      id: 'tarpon',
      name: 'Tarpon',
      scientificName: 'Megalops atlanticus',
      type: 'saltwater',
      rarity: 'rare',
      habitat: 'Coastal waters, channels, and bridges',
      bestBaits: ['Live crabs', 'Large plugs', 'Swimbaits'],
      depthRange: 'Surface to 40 feet',
      season: 'Spring through Summer',
      difficultyRating: 5,
      description: 'The "Silver King" - spectacular jumps and incredible strength!',
      imageAsset: 'assets/images/tarpon.png',
    ),
    const FishSpecies(
      id: 'marlin',
      name: 'Blue Marlin',
      scientificName: 'Makaira nigricans',
      type: 'saltwater',
      rarity: 'legendary',
      habitat: 'Deep offshore waters in tropical and temperate seas',
      bestBaits: ['Large lures', 'Live bait', 'Trolling baits'],
      depthRange: '40-600 feet',
      season: 'Summer',
      difficultyRating: 5,
      description: 'Legendary game fish and trophy of a lifetime. Epic battles!',
      imageAsset: 'assets/images/marlin.png',
    ),
    const FishSpecies(
      id: 'tuna',
      name: 'Bluefin Tuna',
      scientificName: 'Thunnus thynnus',
      type: 'saltwater',
      rarity: 'legendary',
      habitat: 'Deep offshore waters in cold and temperate seas',
      bestBaits: ['Live bait', 'Large jigs', 'Trolling lures'],
      depthRange: '30-400 feet',
      season: 'Spring and Fall',
      difficultyRating: 5,
      description: 'Powerful speedster. Can exceed 1000 pounds. Ultimate challenge!',
      imageAsset: 'assets/images/tuna.png',
    ),
  ];

  static List<FishSpecies> getFishByType(String type) {
    return allFish.where((fish) => fish.type == type).toList();
  }

  static List<FishSpecies> getFishByRarity(String rarity) {
    return allFish.where((fish) => fish.rarity == rarity).toList();
  }

  static FishSpecies? getFishById(String id) {
    try {
      return allFish.firstWhere((fish) => fish.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<FishSpecies> searchFish(String query) {
    final lowerQuery = query.toLowerCase();
    return allFish.where((fish) {
      return fish.name.toLowerCase().contains(lowerQuery) ||
          fish.scientificName.toLowerCase().contains(lowerQuery) ||
          fish.habitat.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<FishSpecies> getRandomFish(int count) {
    final shuffled = List<FishSpecies>.from(allFish)..shuffle();
    return shuffled.take(count).toList();
  }
}
