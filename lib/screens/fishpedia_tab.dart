import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/fish_database.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../widgets/frosted_app_bar.dart';
import 'settings_tab.dart';
import 'unlock_fish_screen.dart';

class FishpediaTab extends StatefulWidget {
  const FishpediaTab({super.key});

  @override
  State<FishpediaTab> createState() => _FishpediaTabState();
}

class _FishpediaTabState extends State<FishpediaTab> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allFish = FishDatabase.allFish;
    var filteredFish = allFish;

    if (_selectedCategory != 'all') {
      filteredFish = filteredFish.where((f) => f.type == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredFish = filteredFish
          .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: FrostedAppBar(
            title: 'FISHPEDIA',
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnlockFishScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                        UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(color: UnderwaterTheme.textLight.withOpacity(0.6), width: 2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: UnderwaterTheme.glowCyan(opacity: 0.2, blur: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.token, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${appProvider.userProfile?.baitTokens ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsTab(),
                        ),
                      );
                    },
                    tooltip: 'Settings',
                  ),
                  if (appProvider.hasNewAchievements)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: UnderwaterTheme.textLight),
              decoration: InputDecoration(
                hintText: 'Search for fish species...',
                hintStyle: TextStyle(color: UnderwaterTheme.textLight.withOpacity(0.6)),
                prefixIcon: const Icon(Icons.search, color: UnderwaterTheme.surfaceCyan1),
                filled: true,
                fillColor: UnderwaterTheme.deepNavy1.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: const BorderSide(color: UnderwaterTheme.surfaceCyan1, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _CategoryButton(
                  label: 'ALL',
                  isSelected: _selectedCategory == 'all',
                  onTap: () => setState(() => _selectedCategory = 'all'),
                ),
                const SizedBox(width: 8),
                _CategoryButton(
                  label: 'FRESHWATER',
                  isSelected: _selectedCategory == 'freshwater',
                  onTap: () => setState(() => _selectedCategory = 'freshwater'),
                ),
                const SizedBox(width: 8),
                _CategoryButton(
                  label: 'SALTWATER',
                  isSelected: _selectedCategory == 'saltwater',
                  onTap: () => setState(() => _selectedCategory = 'saltwater'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredFish.length,
              itemBuilder: (context, index) {
                final fish = filteredFish[index];
                return _FishCard(fish: fish);
              },
            ),
          ),
        ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? const LinearGradient(
                    colors: [
                      UnderwaterTheme.surfaceCyan1,
                      UnderwaterTheme.surfaceCyan2,
                    ],
                  )
                : LinearGradient(
                    colors: [
                      UnderwaterTheme.deepNavy1.withOpacity(0.6),
                      UnderwaterTheme.deepNavy2.withOpacity(0.7),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isSelected 
                  ? UnderwaterTheme.surfaceCyan1 
                  : UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: isSelected 
                ? UnderwaterTheme.glowCyan(opacity: 0.3, blur: 12)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? UnderwaterTheme.deepNavy2 : UnderwaterTheme.textLight,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
              shadows: isSelected 
                  ? null
                  : UnderwaterTheme.textShadowLight,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _FishCard extends StatelessWidget {
  final fish;

  const _FishCard({required this.fish});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    UnderwaterTheme.deepNavy1,
                    UnderwaterTheme.deepNavy2,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                          UnderwaterTheme.surfaceCyan2.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusMedium),
                        topRight: Radius.circular(AppTheme.radiusMedium),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            fish.name,
                            style: const TextStyle(
                              color: UnderwaterTheme.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: UnderwaterTheme.textShadowLight,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: UnderwaterTheme.textLight),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  // Fish Image
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            UnderwaterTheme.deepNavy1.withOpacity(0.8),
                            UnderwaterTheme.deepNavy2.withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: Image.asset(
                        fish.imageAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.waves,
                            size: 64,
                            color: UnderwaterTheme.surfaceCyan1,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scientific Name
                        const Text(
                          'SCIENTIFIC NAME',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: UnderwaterTheme.textCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fish.scientificName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: UnderwaterTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Type & Rarity
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TYPE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: UnderwaterTheme.textCyan,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fish.type.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: UnderwaterTheme.surfaceCyan1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'RARITY',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: UnderwaterTheme.textCyan,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          UnderwaterTheme.surfaceCyan1,
                                          UnderwaterTheme.surfaceCyan2,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 6),
                                    ),
                                    child: Text(
                                      fish.rarity.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: UnderwaterTheme.deepNavy2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: UnderwaterTheme.textCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fish.description,
                          style: const TextStyle(
                            color: UnderwaterTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Habitat
                        const Text(
                          'HABITAT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: UnderwaterTheme.textCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fish.habitat,
                          style: const TextStyle(
                            color: UnderwaterTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Habitat Map
                        // Map removed as it was location-based
                        const SizedBox(height: 16),
                        Text(
                          'HABITAT MAP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: UnderwaterTheme.textCyan,
                          ),
                        ),
                        
                        // Best Baits
                        const Text(
                          'BEST BAITS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: UnderwaterTheme.textCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: fish.bestBaits.map<Widget>((bait) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    UnderwaterTheme.midPeriwinkle.withOpacity(0.5),
                                    UnderwaterTheme.midLavender.withOpacity(0.4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: UnderwaterTheme.midPeriwinkle.withOpacity(0.7),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                bait,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: UnderwaterTheme.textLight,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        
                        // Depth & Season
                        Row(
                          children: [
                            const Icon(Icons.water, size: 16, color: UnderwaterTheme.surfaceCyan1),
                            const SizedBox(width: 4),
                            Text(
                              'Depth: ${fish.depthRange}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: UnderwaterTheme.textLight,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today, size: 16, color: UnderwaterTheme.surfaceCyan1),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                fish.season,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: UnderwaterTheme.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Difficulty
                        Row(
                          children: [
                            const Text(
                              'Difficulty: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: UnderwaterTheme.textLight,
                              ),
                            ),
                            ...List.generate(5, (index) {
                              return Icon(
                                index < fish.difficultyRating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: UnderwaterTheme.surfaceCyan1,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              UnderwaterTheme.deepNavy1.withOpacity(0.8),
              UnderwaterTheme.deepNavy2.withOpacity(0.9),
            ],
          ),
          border: Border.all(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: UnderwaterTheme.glowCyan(opacity: 0.15, blur: 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium - 2),
                  topRight: Radius.circular(AppTheme.radiusMedium - 2),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UnderwaterTheme.deepNavy1.withOpacity(0.6),
                          UnderwaterTheme.deepNavy2.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Image.asset(
                      fish.imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.waves,
                          size: 48,
                          color: UnderwaterTheme.surfaceCyan1,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fish.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: UnderwaterTheme.textLight,
                            shadows: UnderwaterTheme.textShadowLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fish.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: UnderwaterTheme.textCyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            UnderwaterTheme.surfaceCyan1,
                            UnderwaterTheme.surfaceCyan2,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppTheme.radiusMedium - 2),
                          bottomRight: Radius.circular(AppTheme.radiusMedium - 2),
                        ),
                        boxShadow: UnderwaterTheme.glowCyan(opacity: 0.3, blur: 8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'VIEW DETAILS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: UnderwaterTheme.deepNavy2,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: UnderwaterTheme.deepNavy2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
