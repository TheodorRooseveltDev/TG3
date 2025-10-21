import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../widgets/frosted_app_bar.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(
        title: 'ACHIEVEMENTS',
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            final achievements = appProvider.achievements;
            final unlocked = appProvider.unlockedAchievements;
            final total = achievements.length;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + kToolbarHeight - 32,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Column(
                        children: [
                          // Progress Header in Frosted Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      UnderwaterTheme.deepNavy1.withOpacity(0.7),
                                      UnderwaterTheme.deepNavy2.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  border: Border.all(
                                    color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'OVERALL PROGRESS',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: UnderwaterTheme.surfaceCyan1.withOpacity(0.8),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        Text(
                                          '$unlocked/$total',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: UnderwaterTheme.textLight,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: UnderwaterTheme.deepNavy2.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: total > 0 ? unlocked / total : 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                UnderwaterTheme.surfaceCyan1,
                                                UnderwaterTheme.upperAqua1,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: UnderwaterTheme.glowCyan(opacity: 0.5, blur: 8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Achievement Grid
                          Transform.translate(
                            offset: const Offset(0, -86),
                            child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: achievements.length,
                            itemBuilder: (context, index) {
                              final achievement = achievements[index];
                              return _AchievementCard(achievement: achievement);
                            },
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      UnderwaterTheme.surfaceCyan1.withOpacity(0.25),
                      UnderwaterTheme.upperAqua1.withOpacity(0.2),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      UnderwaterTheme.deepNavy1.withOpacity(0.6),
                      UnderwaterTheme.deepNavy2.withOpacity(0.5),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: achievement.isUnlocked
                  ? UnderwaterTheme.surfaceCyan1
                  : UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: achievement.isUnlocked
                ? UnderwaterTheme.glowCyan(opacity: 0.4, blur: 12)
                : null,
          ),
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: 40,
              color: achievement.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: UnderwaterTheme.textLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 10,
              color: UnderwaterTheme.textLight.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!achievement.isUnlocked)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${achievement.currentProgress}/${achievement.requiredCount}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: UnderwaterTheme.surfaceCyan1,
                ),
              ),
            ),
          if (achievement.isUnlocked)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/icon_bbc_bait_token.png',
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.tokenReward}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: UnderwaterTheme.surfaceCyan1,
                    ),
                  ),
                ],
              ),
            ),
        ],
          ),
        ),
      ),
    );
  }
}
