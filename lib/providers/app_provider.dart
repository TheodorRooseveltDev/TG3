import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/catch_entry.dart';
import '../models/daily_quest.dart';
import '../models/achievement.dart';
import '../models/completed_quest.dart';
import '../models/fish_species.dart';
import '../models/app_preferences.dart';
import '../services/fish_database.dart';
import '../services/achievement_database.dart';

class AppProvider with ChangeNotifier {
  UserProfile? _userProfile;
  List<CatchEntry> _catches = [];
  DailyQuest? _currentQuest;
  List<Achievement> _achievements = [];
  List<CompletedQuest> _questHistory = [];
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;
  Set<String> _viewedAchievementIds = {};
  List<Achievement> _newlyUnlockedAchievements = [];
  AppPreferences _preferences = const AppPreferences();

  // Getters
  UserProfile? get userProfile => _userProfile;
  AppPreferences get preferences => _preferences;
  List<CatchEntry> get catches => _catches;
  DailyQuest? get currentQuest => _currentQuest;
  List<Achievement> get achievements => _achievements;
  List<CompletedQuest> get questHistory => _questHistory;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasNewAchievements => _achievements.any((a) => a.isUnlocked && !_viewedAchievementIds.contains(a.id));
  List<Achievement> get newlyUnlockedAchievements => List.unmodifiable(_newlyUnlockedAchievements);

  int get totalCatches => _catches.length;
  int get uniqueSpecies => _catches.map((c) => c.fishSpeciesId).toSet().length;
  int get trophyCatches => _catches.where((c) => c.isTrophyCatch).length;
  int get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).length;

  // Initialize the app
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('onboarding_complete') ?? false;

    if (_hasCompletedOnboarding) {
      await _loadUserProfile();
      await _loadCatches();
      await _loadCurrentQuest();
      await _loadAchievements();
      await _loadQuestHistory();
      await _loadViewedAchievements();
      await _loadPreferences();
      _checkAndUpdateStreaks();
      await _checkQuestExpiration();
    }

    _isLoading = false;
    notifyListeners();
  }

  // User Profile Management
  Future<void> createUserProfile(UserProfile profile) async {
    _userProfile = profile;
    _hasCompletedOnboarding = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(profile.toJson()));
    await prefs.setBool('onboarding_complete', true);

    // Initialize achievements
    _achievements = AchievementDatabase.allAchievements
        .map((a) => a.copyWith())
        .toList();
    await _saveAchievements();

    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(profile.toJson()));
    notifyListeners();
  }

  Future<void> updateProfileAvatar(String? avatarPath) async {
    if (_userProfile == null) return;
    
    _userProfile = _userProfile!.copyWith(avatarPath: avatarPath);
    await updateUserProfile(_userProfile!);
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(jsonDecode(profileJson));
    }
  }

  // Quest Management
  Future<void> spinForQuest() async {
    if (_userProfile == null) return;
    
    // Spend 1 token for spinning
    if (_userProfile!.baitTokens < 1) return;
    await spendBaitTokens(1);

    // Get only unlocked fish for quest
    final availableFish = availableFishForQuest;
    if (availableFish.length < 3) {
      // Fallback to all fish if not enough unlocked
      final targetFish = FishDatabase.getRandomFish(3);
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

      _currentQuest = DailyQuest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetFish: targetFish,
        createdAt: now,
        expiresAt: tomorrow,
      );
    } else {
      // Select 3 random unlocked fish
      final shuffled = List<FishSpecies>.from(availableFish)..shuffle();
      final targetFish = shuffled.take(3).toList();
      
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

      _currentQuest = DailyQuest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetFish: targetFish,
        createdAt: now,
        expiresAt: tomorrow,
      );
    }

    await _saveCurrentQuest();
    notifyListeners();
  }

  Future<void> deleteCurrentQuest() async {
    if (_userProfile == null) return;

    // Remove the current quest
    _currentQuest = null;
    await _saveCurrentQuest();
    notifyListeners();
  }

  Future<void> _loadCurrentQuest() async {
    final prefs = await SharedPreferences.getInstance();
    final questJson = prefs.getString('current_quest');
    if (questJson != null) {
      final quest = DailyQuest.fromJson(jsonDecode(questJson));
      
      // Check if quest is still valid
      if (quest.expiresAt.isAfter(DateTime.now())) {
        _currentQuest = quest;
      } else {
        _currentQuest = null;
        await prefs.remove('current_quest');
      }
    }
  }

  Future<void> _saveCurrentQuest() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentQuest != null) {
      await prefs.setString(
        'current_quest',
        jsonEncode(_currentQuest!.toJson()),
      );
    } else {
      await prefs.remove('current_quest');
    }
  }

  Future<void> _checkQuestExpiration() async {
    if (_currentQuest != null && _currentQuest!.expiresAt.isBefore(DateTime.now())) {
      _currentQuest = null;
      await _saveCurrentQuest();
      notifyListeners();
    }
  }

  // Quest History Management
  Future<void> _loadQuestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('quest_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _questHistory = decoded.map((q) => CompletedQuest.fromJson(q)).toList();
    }
  }

  Future<void> _saveQuestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        jsonEncode(_questHistory.map((q) => q.toJson()).toList());
    await prefs.setString('quest_history', historyJson);
  }

  Future<void> _addToQuestHistory(DailyQuest quest) async {
    final completedQuest = CompletedQuest(
      id: quest.id,
      targetFishIds: quest.targetFish.map((f) => f.id).toList(),
      targetFishNames: quest.targetFish.map((f) => f.name).toList(),
      completedAt: DateTime.now(),
      tokensEarned: 2,
      completionTime: DateTime.now().difference(quest.createdAt),
    );
    
    _questHistory.insert(0, completedQuest);
    
    // Keep only last 50 quests to avoid excessive storage
    if (_questHistory.length > 50) {
      _questHistory = _questHistory.take(50).toList();
    }
    
    await _saveQuestHistory();
  }

  // Catch Management
  Future<void> addCatch(CatchEntry catch_) async {
    // Check if this is a personal best for this species
    final isPersonalBest = _checkPersonalBest(catch_);
    final updatedCatch = catch_.copyWith(isPersonalBest: isPersonalBest);
    
    _catches.insert(0, updatedCatch);
    await _saveCatches();

    // Check if catch matches current quest
    if (_currentQuest != null) {
      final targetIds =
          _currentQuest!.targetFish.map((f) => f.id).toList();
      if (targetIds.contains(catch_.fishSpeciesId) &&
          !_currentQuest!.caughtFishIds.contains(catch_.fishSpeciesId)) {
        final previousProgress = _currentQuest!.progress;
        final updatedCaughtIds = [
          ..._currentQuest!.caughtFishIds,
          catch_.fishSpeciesId
        ];
        final newProgress = updatedCaughtIds.length;
        final total = _currentQuest!.total;
        
        _currentQuest = _currentQuest!.copyWith(
          caughtFishIds: updatedCaughtIds,
          isCompleted: newProgress == total,
        );
        await _saveCurrentQuest();

        // Award tokens at 1/3, 2/3, and 3/3 progress
        if (total == 3) {
          if (newProgress == 1 && previousProgress == 0) {
            await _awardBaitTokens(1); // 1st fish = 1 token
          } else if (newProgress == 2 && previousProgress == 1) {
            await _awardBaitTokens(1); // 2nd fish = 1 token
          } else if (newProgress == 3 && previousProgress == 2) {
            await _awardBaitTokens(1); // 3rd fish = 1 token
            await _addToQuestHistory(_currentQuest!);
            await _incrementStreak();
            await _incrementCompletedQuests();
          }
        } else {
          // For non-3 fish quests, use old system
          if (_currentQuest!.isCompleted) {
            await _addToQuestHistory(_currentQuest!);
            await _incrementStreak();
            await _awardBaitTokens(2);
            await _incrementCompletedQuests();
          }
        }
      }
    }

    // Update achievements
    await _updateAchievements(catch_);
    
    // Check weekly challenges
    await checkWeeklyChallenges();

    notifyListeners();
  }

  Future<void> deleteCatch(CatchEntry catchEntry) async {
    _catches.removeWhere((c) => c.id == catchEntry.id);
    await _saveCatches();
    notifyListeners();
  }

  bool _checkPersonalBest(CatchEntry newCatch) {
    // Get all previous catches of the same species
    final sameFishCatches = _catches.where((c) => 
      c.fishSpeciesId == newCatch.fishSpeciesId
    ).toList();
    
    if (sameFishCatches.isEmpty) {
      // First catch of this species is always a personal best
      return true;
    }
    
    // Check if this catch is heavier than all previous catches
    final newWeight = newCatch.weight ?? 0;
    final maxPreviousWeight = sameFishCatches
        .map((c) => c.weight ?? 0)
        .reduce((a, b) => a > b ? a : b);
    
    return newWeight > maxPreviousWeight;
  }

  Future<void> updateCatch(CatchEntry updatedCatch) async {
    final index = _catches.indexWhere((c) => c.id == updatedCatch.id);
    if (index != -1) {
      // Re-check personal best status
      final otherCatches = _catches.where((c) => c.id != updatedCatch.id).toList();
      final sameFishCatches = otherCatches.where((c) => 
        c.fishSpeciesId == updatedCatch.fishSpeciesId
      ).toList();
      
      bool isPersonalBest = true;
      if (sameFishCatches.isNotEmpty) {
        final newWeight = updatedCatch.weight ?? 0;
        final maxOtherWeight = sameFishCatches
            .map((c) => c.weight ?? 0)
            .reduce((a, b) => a > b ? a : b);
        isPersonalBest = newWeight > maxOtherWeight;
      }
      
      _catches[index] = updatedCatch.copyWith(isPersonalBest: isPersonalBest);
      await _saveCatches();
      notifyListeners();
    }
  }

  Future<void> _saveCatches() async {
    final prefs = await SharedPreferences.getInstance();
    final catchesJson =
        jsonEncode(_catches.map((c) => c.toJson()).toList());
    await prefs.setString('catches', catchesJson);
  }

  Future<void> _loadCatches() async {
    final prefs = await SharedPreferences.getInstance();
    final catchesJson = prefs.getString('catches');
    if (catchesJson != null) {
      final List<dynamic> decoded = jsonDecode(catchesJson);
      _catches = decoded.map((c) => CatchEntry.fromJson(c)).toList();
    }
  }

  List<CatchEntry> getCatchesByFilter(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'today':
        return _catches.where((c) {
          return c.caughtAt.year == now.year &&
              c.caughtAt.month == now.month &&
              c.caughtAt.day == now.day;
        }).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return _catches.where((c) => c.caughtAt.isAfter(weekAgo)).toList();
      case 'month':
        return _catches.where((c) {
          return c.caughtAt.year == now.year && c.caughtAt.month == now.month;
        }).toList();
      case 'trophy':
        return _catches.where((c) => c.isTrophyCatch).toList();
      default:
        return _catches;
    }
  }

  List<CatchEntry> sortCatches(String sortBy) {
    final sorted = List<CatchEntry>.from(_catches);
    switch (sortBy) {
      case 'date-desc':
        sorted.sort((a, b) => b.caughtAt.compareTo(a.caughtAt));
        break;
      case 'date-asc':
        sorted.sort((a, b) => a.caughtAt.compareTo(b.caughtAt));
        break;
      case 'weight-desc':
        sorted.sort((a, b) =>
            (b.weight ?? 0).compareTo(a.weight ?? 0));
        break;
      case 'length-desc':
        sorted.sort((a, b) =>
            (b.length ?? 0).compareTo(a.length ?? 0));
        break;
    }
    return sorted;
  }

  // Streak Management
  void _checkAndUpdateStreaks() {
    if (_userProfile == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveDay = DateTime(
      _userProfile!.lastActive.year,
      _userProfile!.lastActive.month,
      _userProfile!.lastActive.day,
    );
    
    final daysDifference = today.difference(lastActiveDay).inDays;

    // Only break streak if more than 1 day has passed
    // (1 day = yesterday, which is OK as long as we complete a quest today)
    if (daysDifference > 1) {
      // Streak broken - reset both daily and weekly
      _userProfile = _userProfile!.copyWith(
        dailyStreak: 0,
        weeklyStreak: 0,
        lastActive: now,
      );
      updateUserProfile(_userProfile!);
    }
    // Note: We don't update lastActive here for daysDifference == 1
    // because that should only happen when completing a quest
  }

  Future<void> _incrementStreak() async {
    if (_userProfile == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveDay = DateTime(
      _userProfile!.lastActive.year,
      _userProfile!.lastActive.month,
      _userProfile!.lastActive.day,
    );

    // Only increment if we haven't already incremented today
    if (today.isAfter(lastActiveDay)) {
      final newDailyStreak = _userProfile!.dailyStreak + 1;
      
      // Weekly streak increments every time we complete a full 7-day period
      final newWeeklyStreak = newDailyStreak % 7 == 0
          ? _userProfile!.weeklyStreak + 1
          : _userProfile!.weeklyStreak;

      _userProfile = _userProfile!.copyWith(
        dailyStreak: newDailyStreak,
        weeklyStreak: newWeeklyStreak,
        lastActive: now, // Critical: Update lastActive!
      );
      await updateUserProfile(_userProfile!);
    }
  }

  Future<void> _awardBaitTokens(int amount) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(
      baitTokens: _userProfile!.baitTokens + amount,
    );
    await updateUserProfile(_userProfile!);
  }

  Future<void> spendBaitTokens(int amount) async {
    if (_userProfile == null || _userProfile!.baitTokens < amount) return;

    _userProfile = _userProfile!.copyWith(
      baitTokens: _userProfile!.baitTokens - amount,
    );
    await updateUserProfile(_userProfile!);
    notifyListeners();
  }

  Future<bool> unlockFish(String fishId, int cost) async {
    if (_userProfile == null) return false;
    if (_userProfile!.baitTokens < cost) return false;
    if (_userProfile!.unlockedFishIds.contains(fishId)) return false;

    final newUnlockedIds = [..._userProfile!.unlockedFishIds, fishId];
    _userProfile = _userProfile!.copyWith(
      baitTokens: _userProfile!.baitTokens - cost,
      unlockedFishIds: newUnlockedIds,
    );
    await updateUserProfile(_userProfile!);
    notifyListeners();
    return true;
  }

  bool isFishUnlocked(String fishId) {
    if (_userProfile == null) return true;
    // Common fish are always unlocked
    final fish = FishDatabase.getFishById(fishId);
    if (fish == null) return true;
    if (fish.rarity == 'common') return true;
    return _userProfile!.unlockedFishIds.contains(fishId);
  }

  List<FishSpecies> get availableFishForQuest {
    // Get all fish that are unlocked
    return FishDatabase.allFish.where((fish) {
      return fish.rarity == 'common' || 
             (_userProfile?.unlockedFishIds.contains(fish.id) ?? false);
    }).toList();
  }

  int getUnlockCost(FishSpecies fish) {
    switch (fish.rarity) {
      case 'common':
        return 0; // Always unlocked
      case 'uncommon':
        return 2;
      case 'rare':
        return 4;
      case 'legendary':
        return 8;
      default:
        return 2;
    }
  }

  Future<void> _incrementCompletedQuests() async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(
      completedQuests: _userProfile!.completedQuests + 1,
    );
    await updateUserProfile(_userProfile!);
    await _updateQuestAchievements();
  }

  // Achievement Management
  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString('achievements');
    if (achievementsJson != null) {
      final List<dynamic> decoded = jsonDecode(achievementsJson);
      _achievements =
          decoded.map((a) => Achievement.fromJson(a)).toList();
    } else {
      _achievements = AchievementDatabase.allAchievements
          .map((a) => a.copyWith())
          .toList();
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson =
        jsonEncode(_achievements.map((a) => a.toJson()).toList());
    await prefs.setString('achievements', achievementsJson);
  }

  Future<void> _loadViewedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final viewedJson = prefs.getString('viewed_achievements');
    if (viewedJson != null) {
      final List<dynamic> decoded = jsonDecode(viewedJson);
      _viewedAchievementIds = Set<String>.from(decoded);
    }
  }

  Future<void> _saveViewedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('viewed_achievements', jsonEncode(_viewedAchievementIds.toList()));
  }

  // Preferences Management
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString('app_preferences');
    if (prefsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(prefsJson);
      _preferences = AppPreferences.fromJson(decoded);
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_preferences', jsonEncode(_preferences.toJson()));
  }

  Future<void> updatePreferences(AppPreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();
    notifyListeners();
  }

  Future<void> markAchievementsAsViewed() async {
    _viewedAchievementIds.addAll(
      _achievements.where((a) => a.isUnlocked).map((a) => a.id)
    );
    await _saveViewedAchievements();
    notifyListeners();
  }

  Future<void> _updateAchievements(CatchEntry catch_) async {
    bool updated = false;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      int newProgress = achievement.currentProgress;

      switch (achievement.id) {
        // Catches category
        case 'first_catch':
          newProgress = totalCatches;
          break;
        case 'rookie_angler':
          newProgress = totalCatches;
          break;
        case 'experienced_fisher':
          newProgress = totalCatches;
          break;
        case 'master_angler':
          newProgress = totalCatches;
          break;
        case 'trophy_hunter':
          newProgress = trophyCatches;
          break;
        case 'photo_collector':
          newProgress =
              _catches.where((c) => c.photoPath != null).length;
          break;
        case 'big_catch':
          if (catch_.weight != null && catch_.weight! > 10) {
            newProgress = 1;
          }
          break;
        case 'rare_find':
          final rareFish = FishDatabase.getFishById(catch_.fishSpeciesId);
          if (rareFish?.rarity == 'rare') {
            newProgress = 1;
          }
          break;
        case 'legendary_catch':
          final legendaryFish = FishDatabase.getFishById(catch_.fishSpeciesId);
          if (legendaryFish?.rarity == 'legendary') {
            newProgress = 1;
          }
          break;
        
        // Streaks category
        case 'dedication':
          newProgress = _userProfile?.dailyStreak ?? 0;
          break;
        case 'perfect_week':
          if (_userProfile != null && _userProfile!.dailyStreak >= 7) {
            newProgress = 1;
          }
          break;
        case 'monthly_master':
          if (_userProfile != null && _userProfile!.dailyStreak >= 30) {
            newProgress = 1;
          }
          break;
        case 'unstoppable':
          if (_userProfile != null && _userProfile!.dailyStreak >= 100) {
            newProgress = 1;
          }
          break;
        
        // Collection category
        case 'freshwater_explorer':
          final freshwaterCaught = _catches
              .map((c) => c.fishSpeciesId)
              .toSet()
              .where((id) => FishDatabase.getFishById(id)?.type == 'freshwater')
              .length;
          newProgress = freshwaterCaught;
          break;
        case 'saltwater_specialist':
          final saltwaterCaught = _catches
              .map((c) => c.fishSpeciesId)
              .toSet()
              .where((id) => FishDatabase.getFishById(id)?.type == 'saltwater')
              .length;
          newProgress = saltwaterCaught;
          break;
        case 'complete_collection':
          newProgress = uniqueSpecies;
          break;
        case 'diversity_master':
          newProgress = uniqueSpecies;
          break;
        
        // Quests category
        case 'quest_starter':
          // This needs to be tracked when quests are completed
          // Will be updated in quest completion logic
          break;
        case 'quest_warrior':
          // Tracked on quest completion
          break;
        case 'quest_master':
          // Tracked on quest completion
          break;
        case 'dedicated_quester':
          // Tracked on quest completion
          break;
      }

      if (newProgress != achievement.currentProgress) {
        final wasUnlocked = achievement.isUnlocked;
        final nowUnlocked = newProgress >= achievement.requiredCount;
        
        _achievements[i] = achievement.copyWith(
          currentProgress: newProgress,
          isUnlocked: nowUnlocked,
          unlockedAt: nowUnlocked
              ? DateTime.now()
              : null,
        );
        
        // Track if this is a new unlock and award tokens
        if (!wasUnlocked && nowUnlocked) {
          _newlyUnlockedAchievements.add(_achievements[i]);
          // Award bait tokens based on achievement category
          await _awardAchievementReward(achievement);
        }
        
        updated = true;
      }
    }

    if (updated) {
      await _saveAchievements();
    }
  }

  // Award bait tokens for achievement unlocks
  Future<void> _awardAchievementReward(Achievement achievement) async {
    int tokenReward = 0;
    
    // Token rewards based on category and difficulty
    switch (achievement.category) {
      case 'catches':
        if (achievement.requiredCount >= 100) {
          tokenReward = 10; // Master achievements
        } else if (achievement.requiredCount >= 50) {
          tokenReward = 5; // Advanced achievements
        } else if (achievement.requiredCount >= 10) {
          tokenReward = 3; // Intermediate achievements
        } else {
          tokenReward = 1; // Beginner achievements
        }
        break;
      
      case 'streaks':
        if (achievement.requiredCount >= 100) {
          tokenReward = 15; // Legendary streak
        } else if (achievement.requiredCount >= 30) {
          tokenReward = 8; // Monthly streak
        } else if (achievement.requiredCount >= 7) {
          tokenReward = 4; // Weekly streak
        } else {
          tokenReward = 2;
        }
        break;
      
      case 'collection':
        if (achievement.requiredCount >= 50) {
          tokenReward = 10; // Master collector
        } else if (achievement.requiredCount >= 20) {
          tokenReward = 6; // Advanced collector
        } else {
          tokenReward = 3;
        }
        break;
      
      case 'quests':
        if (achievement.requiredCount >= 100) {
          tokenReward = 12;
        } else if (achievement.requiredCount >= 50) {
          tokenReward = 7;
        } else if (achievement.requiredCount >= 10) {
          tokenReward = 4;
        } else {
          tokenReward = 2;
        }
        break;
      
      default:
        tokenReward = 2; // Default reward
    }
    
    await _awardBaitTokens(tokenReward);
  }

  // Track completed quests for achievements
  Future<void> _updateQuestAchievements() async {
    if (_userProfile == null) return;
    
    bool updated = false;
    final completedQuests = _userProfile!.completedQuests;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      int newProgress = achievement.currentProgress;

      switch (achievement.id) {
        case 'quest_starter':
          newProgress = completedQuests;
          break;
        case 'quest_warrior':
          newProgress = completedQuests;
          break;
        case 'quest_master':
          newProgress = completedQuests;
          break;
        case 'dedicated_quester':
          newProgress = completedQuests;
          break;
      }

      if (newProgress != achievement.currentProgress) {
        final wasUnlocked = achievement.isUnlocked;
        final nowUnlocked = newProgress >= achievement.requiredCount;
        
        _achievements[i] = achievement.copyWith(
          currentProgress: newProgress,
          isUnlocked: nowUnlocked,
          unlockedAt: nowUnlocked
              ? DateTime.now()
              : null,
        );
        
        // Track if this is a new unlock and award tokens
        if (!wasUnlocked && nowUnlocked) {
          _newlyUnlockedAchievements.add(_achievements[i]);
          await _awardAchievementReward(achievement);
        }
        
        updated = true;
      }
    }

    if (updated) {
      await _saveAchievements();
      notifyListeners();
    }
  }

  // Weekly Challenge System
  Future<void> checkWeeklyChallenges() async {
    if (_userProfile == null) return;
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    // Count catches this week
    final weeklyCatches = _catches.where((c) => 
      c.caughtAt.isAfter(weekStartMidnight)
    ).length;
    
    // Count unique species this week
    final weeklyUniqueSpecies = _catches.where((c) => 
      c.caughtAt.isAfter(weekStartMidnight)
    ).map((c) => c.fishSpeciesId).toSet().length;
    
    // Count trophy catches this week
    final weeklyTrophies = _catches.where((c) => 
      c.caughtAt.isAfter(weekStartMidnight) && c.isTrophyCatch
    ).length;
    
    // Weekly Challenge Rewards
    // Challenge 1: Catch 10 fish in a week = 3 tokens
    if (weeklyCatches >= 10) {
      await _checkAndAwardWeeklyChallenge('weekly_10_catches', 3);
    }
    
    // Challenge 2: Catch 5 different species in a week = 4 tokens
    if (weeklyUniqueSpecies >= 5) {
      await _checkAndAwardWeeklyChallenge('weekly_5_species', 4);
    }
    
    // Challenge 3: Catch 3 trophies in a week = 5 tokens
    if (weeklyTrophies >= 3) {
      await _checkAndAwardWeeklyChallenge('weekly_3_trophies', 5);
    }
    
    // Challenge 4: Complete all daily quests this week = 10 tokens
    final dailyQuestsThisWeek = _questHistory.where((q) =>
      q.completedAt.isAfter(weekStartMidnight)
    ).length;
    
    if (dailyQuestsThisWeek >= 7) {
      await _checkAndAwardWeeklyChallenge('weekly_7_quests', 10);
    }
  }

  Future<void> _checkAndAwardWeeklyChallenge(String challengeId, int tokenReward) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Get the current week identifier (year-week)
    final weekNumber = _getWeekNumber(now);
    final weekKey = 'weekly_challenge_${challengeId}_$weekNumber';
    
    // Check if this challenge was already claimed this week
    final alreadyClaimed = prefs.getBool(weekKey) ?? false;
    
    if (!alreadyClaimed) {
      // Award tokens
      await _awardBaitTokens(tokenReward);
      
      // Mark as claimed for this week
      await prefs.setBool(weekKey, true);
      
      // Optional: Clean up old week data (keep last 4 weeks only)
      await _cleanupOldWeeklyChallenges(prefs, weekNumber);
    }
  }

  int _getWeekNumber(DateTime date) {
    final year = date.year;
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor() + 1;
  }

  Future<void> _cleanupOldWeeklyChallenges(SharedPreferences prefs, int currentWeek) async {
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('weekly_challenge_')) {
        // Extract week number from key
        final parts = key.split('_');
        if (parts.length > 3) {
          final weekNum = int.tryParse(parts.last);
          if (weekNum != null && weekNum < currentWeek - 4) {
            await prefs.remove(key);
          }
        }
      }
    }
  }

  // Data Management
  Future<void> deleteAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _userProfile = null;
    _catches = [];
    _currentQuest = null;
    _achievements = [];
    _hasCompletedOnboarding = false;
    _newlyUnlockedAchievements = [];
    
    notifyListeners();
  }

  // Clear newly unlocked achievements after showing them
  void clearNewlyUnlockedAchievements() {
    _newlyUnlockedAchievements.clear();
    notifyListeners();
  }
}
