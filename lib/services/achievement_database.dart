import '../models/achievement.dart';

class AchievementDatabase {
  static final List<Achievement> allAchievements = [
    // Catch Achievements
    const Achievement(
      id: 'first_catch',
      name: 'First Catch',
      description: 'Log your very first fish',
      icon: '🎣',
      requiredCount: 1,
      category: 'catches',
    ),
    const Achievement(
      id: 'rookie_angler',
      name: 'Rookie Angler',
      description: 'Catch 10 fish',
      icon: '🐟',
      requiredCount: 10,
      category: 'catches',
    ),
    const Achievement(
      id: 'experienced_fisher',
      name: 'Experienced Fisher',
      description: 'Catch 50 fish',
      icon: '🎏',
      requiredCount: 50,
      category: 'catches',
    ),
    const Achievement(
      id: 'master_angler',
      name: 'Master Angler',
      description: 'Catch 100 unique fish species',
      icon: '👑',
      requiredCount: 100,
      category: 'catches',
    ),
    const Achievement(
      id: 'trophy_hunter',
      name: 'Trophy Hunter',
      description: 'Catch 5 trophy-sized fish',
      icon: '🏆',
      requiredCount: 5,
      category: 'catches',
    ),

    // Streak Achievements
    const Achievement(
      id: 'dedicated_fisher',
      name: 'Dedicated Fisher',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
      requiredCount: 7,
      category: 'streaks',
    ),
    const Achievement(
      id: 'unstoppable',
      name: 'Unstoppable',
      description: 'Maintain a 30-day streak',
      icon: '⚡',
      requiredCount: 30,
      category: 'streaks',
    ),
    const Achievement(
      id: 'legendary_dedication',
      name: 'Legendary Dedication',
      description: 'Maintain a 100-day streak',
      icon: '💎',
      requiredCount: 100,
      category: 'streaks',
    ),
    const Achievement(
      id: 'perfect_week',
      name: 'Perfect Week',
      description: 'Complete daily quests for 7 consecutive days',
      icon: '⭐',
      requiredCount: 7,
      category: 'quests',
    ),

    // Collection Achievements
    const Achievement(
      id: 'photo_collector',
      name: 'Photo Collector',
      description: 'Log 50 catches with photos',
      icon: '📷',
      requiredCount: 50,
      category: 'collection',
    ),
    const Achievement(
      id: 'species_hunter',
      name: 'Species Hunter',
      description: 'Catch 20 different species',
      icon: '🦈',
      requiredCount: 20,
      category: 'collection',
    ),
    const Achievement(
      id: 'bass_master',
      name: 'Bass Master',
      description: 'Catch 25 bass',
      icon: '🐠',
      requiredCount: 25,
      category: 'collection',
    ),
    const Achievement(
      id: 'trout_specialist',
      name: 'Trout Specialist',
      description: 'Catch 20 trout',
      icon: '🌊',
      requiredCount: 20,
      category: 'collection',
    ),
    const Achievement(
      id: 'saltwater_pro',
      name: 'Saltwater Pro',
      description: 'Catch 30 saltwater species',
      icon: '🌊',
      requiredCount: 30,
      category: 'collection',
    ),
    const Achievement(
      id: 'freshwater_expert',
      name: 'Freshwater Expert',
      description: 'Catch 30 freshwater species',
      icon: '💧',
      requiredCount: 30,
      category: 'collection',
    ),

    // Quest Achievements
    const Achievement(
      id: 'quest_complete',
      name: 'Quest Complete',
      description: 'Complete your first daily quest',
      icon: '✅',
      requiredCount: 1,
      category: 'quests',
    ),
    const Achievement(
      id: 'quest_warrior',
      name: 'Quest Warrior',
      description: 'Complete 10 daily quests',
      icon: '⚔️',
      requiredCount: 10,
      category: 'quests',
    ),
    const Achievement(
      id: 'quest_legend',
      name: 'Quest Legend',
      description: 'Complete 50 daily quests',
      icon: '🛡️',
      requiredCount: 50,
      category: 'quests',
    ),

    // Special Achievements
    const Achievement(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Catch a fish before 6 AM',
      icon: '🌅',
      requiredCount: 1,
      category: 'catches',
    ),
    const Achievement(
      id: 'night_fisher',
      name: 'Night Fisher',
      description: 'Catch a fish after 8 PM',
      icon: '🌙',
      requiredCount: 1,
      category: 'catches',
    ),
    const Achievement(
      id: 'big_catch',
      name: 'Big Catch',
      description: 'Catch a fish over 10 kg (22 lbs)',
      icon: '💪',
      requiredCount: 1,
      category: 'catches',
    ),
    const Achievement(
      id: 'rare_find',
      name: 'Rare Find',
      description: 'Catch a rare species',
      icon: '✨',
      requiredCount: 1,
      category: 'catches',
    ),
    const Achievement(
      id: 'legendary_catch',
      name: 'Legendary Catch',
      description: 'Catch a legendary species',
      icon: '🌟',
      requiredCount: 1,
      category: 'catches',
    ),
    const Achievement(
      id: 'explorer',
      name: 'Explorer',
      description: 'Fish at 10 different locations',
      icon: '🗺️',
      requiredCount: 10,
      category: 'catches',
    ),
  ];

  static List<Achievement> getAchievementsByCategory(String category) {
    return allAchievements
        .where((achievement) => achievement.category == category)
        .toList();
  }

  static Achievement? getAchievementById(String id) {
    try {
      return allAchievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
}
