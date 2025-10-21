import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/underwater_theme.dart';
import '../services/fish_database.dart';
import '../widgets/frosted_app_bar.dart';

class QuestHistoryScreen extends StatelessWidget {
  const QuestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: UnderwaterTheme.deepNavy1,
      appBar: const FrostedAppBar(
        title: 'QUEST HISTORY',
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
          final questHistory = appProvider.questHistory;

          if (questHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppTheme.colorTextMuted.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Quest History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colorTextMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete quests to see them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.colorTextMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.colorPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Total Completed',
                      questHistory.length.toString(),
                      Icons.check_circle,
                    ),
                    _buildStat(
                      'Tokens Earned',
                      questHistory.fold<int>(
                        0,
                        (sum, q) => sum + q.tokensEarned,
                      ).toString(),
                      Icons.monetization_on,
                    ),
                    _buildStat(
                      'This Week',
                      questHistory.where((q) {
                        final weekAgo = DateTime.now().subtract(
                          const Duration(days: 7),
                        );
                        return q.completedAt.isAfter(weekAgo);
                      }).length.toString(),
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ),
              
              // Quest List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questHistory.length,
                  itemBuilder: (context, index) {
                    final quest = questHistory[index];
                    return _buildQuestCard(quest);
                  },
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

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.colorAccent, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.colorTextPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.colorTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestCard(quest) {
    final completedDate = DateFormat('MMM d, y').format(quest.completedAt);
    final completedTime = DateFormat('h:mm a').format(quest.completedAt);
    final hours = quest.completionTime.inHours;
    final minutes = quest.completionTime.inMinutes % 60;
    final timeToComplete = hours > 0
        ? '${hours}h ${minutes}m'
        : '${minutes}m';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.colorSurface,
        border: Border.all(color: AppTheme.colorBorder, width: 2),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.colorSecondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMedium - 2),
                topRight: Radius.circular(AppTheme.radiusMedium - 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'QUEST COMPLETED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '+${quest.tokensEarned} 🪙',
                  style: const TextStyle(
                    color: AppTheme.colorAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Fish Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Fish:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quest.targetFishNames.map<Widget>((fishName) {
                    final fish = FishDatabase.allFish.firstWhere(
                      (f) => f.name == fishName,
                      orElse: () => FishDatabase.allFish[0],
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.colorSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.colorSecondary,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              fish.imageAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.waves,
                                  size: 16,
                                  color: AppTheme.colorSecondary,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            fishName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.colorSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 16,
                          color: AppTheme.colorTextMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeToComplete,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          completedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.colorPrimary,
                          ),
                        ),
                        Text(
                          completedTime,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
