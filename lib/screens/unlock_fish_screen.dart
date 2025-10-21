import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/app_provider.dart';
import '../services/fish_database.dart';
import '../models/fish_species.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../widgets/frosted_app_bar.dart';

class UnlockFishScreen extends StatelessWidget {
  const UnlockFishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: UnderwaterTheme.deepNavy1,
      appBar: const FrostedAppBar(
        title: 'UNLOCK FISH SPECIES',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    MediaQuery.of(context).padding.top + kToolbarHeight - 32,
                    0,
                    0,
                  ),
                  child: Consumer<AppProvider>(
                    builder: (context, appProvider, child) {
                      final allFish = FishDatabase.allFish;
                      
                      // Group by rarity
                      final commonFish = allFish.where((f) => f.rarity == 'common').toList();
                      final uncommonFish = allFish.where((f) => f.rarity == 'uncommon').toList();
                      final rareFish = allFish.where((f) => f.rarity == 'rare').toList();
                      final legendaryFish = allFish.where((f) => f.rarity == 'legendary').toList();

                      return Column(
                        children: [
                          // Token balance header with frosted glass
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        UnderwaterTheme.deepNavy1.withOpacity(0.7),
                                        UnderwaterTheme.deepNavy2.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    border: Border.all(
                                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                                      width: 2,
                                    ),
                                    boxShadow: UnderwaterTheme.glowCyan(opacity: 0.2, blur: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.token, color: UnderwaterTheme.surfaceCyan1, size: 32),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${appProvider.userProfile?.baitTokens ?? 0} Bait Tokens',
                                        style: const TextStyle(
                                          color: UnderwaterTheme.textLight,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: UnderwaterTheme.textShadowLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Info card with frosted glass
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        UnderwaterTheme.deepNavy1.withOpacity(0.7),
                                        UnderwaterTheme.deepNavy2.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    border: Border.all(
                                      color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                                      width: 2,
                                    ),
                                    boxShadow: UnderwaterTheme.glowCyan(opacity: 0.15, blur: 16),
                                  ),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.info_outline, color: UnderwaterTheme.surfaceCyan1, size: 32),
                                      SizedBox(height: 8),
                                      Text(
                                        'Unlock new fish species to catch them and add them to your daily quests!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: UnderwaterTheme.textLight,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Earn tokens by completing daily quests (1 token per fish caught)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: UnderwaterTheme.textCyan,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Fish list
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                    if (commonFish.isNotEmpty) ...[
                      _buildRaritySection('COMMON - Always Unlocked', commonFish, appProvider, context),
                      const SizedBox(height: 16),
                    ],
                    if (uncommonFish.isNotEmpty) ...[
                      _buildRaritySection('UNCOMMON - 2 Tokens Each', uncommonFish, appProvider, context),
                      const SizedBox(height: 16),
                    ],
                    if (rareFish.isNotEmpty) ...[
                      _buildRaritySection('RARE - 4 Tokens Each', rareFish, appProvider, context),
                      const SizedBox(height: 16),
                    ],
                    if (legendaryFish.isNotEmpty) ...[
                      _buildRaritySection('LEGENDARY - 8 Tokens Each', legendaryFish, appProvider, context),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 80),
                  ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRaritySection(String title, List<FishSpecies> fish, AppProvider appProvider, BuildContext context) {
    Color rarityColor;
    if (title.contains('COMMON')) {
      rarityColor = AppTheme.colorTextSecondary;
    } else if (title.contains('UNCOMMON')) rarityColor = Colors.green;
    else if (title.contains('RARE')) rarityColor = Colors.blue;
    else rarityColor = Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: rarityColor,
            ),
          ),
        ),
        ...fish.map((f) => _buildFishCard(f, appProvider, context)),
      ],
    );
  }

  Widget _buildFishCard(FishSpecies fish, AppProvider appProvider, BuildContext context) {
    final isUnlocked = appProvider.isFishUnlocked(fish.id);
    final cost = appProvider.getUnlockCost(fish);
    final canAfford = (appProvider.userProfile?.baitTokens ?? 0) >= cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? AppTheme.colorSuccess.withOpacity(0.05)
            : AppTheme.colorSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isUnlocked 
              ? AppTheme.colorSuccess 
              : AppTheme.colorBorder,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.colorBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          clipBehavior: Clip.antiAlias,
          child: isUnlocked
              ? Image.asset(
                  fish.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.waves, color: AppTheme.colorSecondary);
                  },
                )
              : const Icon(Icons.lock, color: AppTheme.colorTextMuted, size: 32),
        ),
        title: Text(
          fish.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? AppTheme.colorSuccess : AppTheme.colorTextPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fish.scientificName,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.colorTextMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fish.type == 'freshwater' ? '🌊 Freshwater' : '🌊 Saltwater',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: isUnlocked
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.colorSuccess,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'UNLOCKED',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : cost == 0
                ? const SizedBox.shrink()
                : ElevatedButton(
                    onPressed: canAfford
                        ? () => _unlockFish(context, appProvider, fish, cost)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford
                          ? AppTheme.colorSecondary
                          : AppTheme.colorTextMuted,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.token, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'UNLOCK $cost',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  void _unlockFish(BuildContext context, AppProvider appProvider, FishSpecies fish, int cost) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Unlock ${fish.name}?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: UnderwaterTheme.textLight,
                  shadows: UnderwaterTheme.textShadowLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      UnderwaterTheme.deepNavy2.withOpacity(0.6),
                      UnderwaterTheme.cardPurpleMid.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  fish.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.waves, size: 60, color: UnderwaterTheme.surfaceCyan1);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                fish.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: UnderwaterTheme.textCyan,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      UnderwaterTheme.surfaceCyan1.withOpacity(0.2),
                      UnderwaterTheme.surfaceCyan2.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.token, color: UnderwaterTheme.surfaceCyan1, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Cost: $cost Bait Tokens',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: UnderwaterTheme.textLight,
                            shadows: UnderwaterTheme.textShadowLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have: ${appProvider.userProfile?.baitTokens ?? 0} tokens',
                      style: TextStyle(
                        color: UnderwaterTheme.textCyan.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: UnderwaterTheme.textCyan,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          side: BorderSide(
                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await appProvider.unlockFish(fish.id, cost);
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${fish.name} unlocked! It can now appear in your daily quests.'),
                                backgroundColor: UnderwaterTheme.surfaceCyan1,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UnderwaterTheme.surfaceCyan1,
                        foregroundColor: UnderwaterTheme.deepNavy2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ).copyWith(
                        shadowColor: WidgetStateProperty.all(
                          UnderwaterTheme.surfaceCyan1.withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        'UNLOCK',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
