import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'water_intake_service.dart';

part 'rewards_service.g.dart';

@riverpod
class RewardsNotifier extends _$RewardsNotifier {
  @override
  Map<String, dynamic> build() {
    return {
      'badges': _getBadges(),
      'achievements': _getAchievements(),
      'goalReachedToday': false,
      'newlyUnlockedBadges': <String>[],
      'newlyCompletedAchievements': <String>[],
    };
  }

  List<Map<String, dynamic>> _getBadges() {
    return [
      {
        'id': 'first_drop',
        'name': 'First Drop',
        'description': 'Add your first drink',
        'icon': 'water_drop',
        'unlocked': false, // Will be updated in checkAndAwardBadges
        'condition': 'Add your first drink',
      },
      {
        'id': 'goal_crusher',
        'name': 'Goal Crusher',
        'description': 'Reach daily goal',
        'icon': 'flag',
        'unlocked': false, // Will be updated in checkAndAwardBadges
        'condition': 'Reach your daily water intake goal',
      },
      {
        'id': 'streak_master',
        'name': 'Streak Master',
        'description': '7 days in a row',
        'icon': 'local_fire_department',
        'unlocked': false, // Will be updated in checkAndAwardBadges
        'condition': 'Maintain hydration for 7 consecutive days',
      },
      {
        'id': 'hydration_hero',
        'name': 'Hydration Hero',
        'description': 'Drink 3L in a day',
        'icon': 'emoji_events',
        'unlocked': false, // Will be updated in checkAndAwardBadges
        'condition': 'Drink 3 liters of water in a single day',
      },
      {
        'id': 'variety_seeker',
        'name': 'Variety Seeker',
        'description': 'Try 5 different drinks',
        'icon': 'local_bar',
        'unlocked': false, // Will be updated in checkAndAwardBadges
        'condition': 'Try 5 different types of drinks',
      },
      {
        'id': 'consistency_king',
        'name': 'Consistency King',
        'description': '30 days streak',
        'icon': 'crown',
        'unlocked': false, // Will be updated in checkAndAwardBadges
        'condition': 'Maintain hydration for 30 consecutive days',
      },
    ];
  }

  List<Map<String, dynamic>> _getAchievements() {
    return [
      {
        'id': 'goal_achiever',
        'title': 'Goal Achiever',
        'description': 'Reach your daily water intake goal',
        'icon': 'flag',
        'completed': false, // Will be updated in checkAndAwardBadges
      },
      {
        'id': 'week_warrior',
        'title': 'Week Warrior',
        'description': 'Maintain your hydration for 7 consecutive days',
        'icon': 'local_fire_department',
        'completed': false, // Will be updated in checkAndAwardBadges
      },
      {
        'id': 'hydration_master',
        'title': 'Hydration Master',
        'description': 'Drink 3 liters of water in a single day',
        'icon': 'emoji_events',
        'completed': false, // Will be updated in checkAndAwardBadges
      },
    ];
  }

  Future<bool> _isBadgeUnlocked(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('badge_$badgeId') ?? false;
  }

  Future<bool> _isAchievementCompleted(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('achievement_$achievementId') ?? false;
  }

  Future<void> unlockBadge(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final wasAlreadyUnlocked = prefs.getBool('badge_$badgeId') ?? false;
    
    if (!wasAlreadyUnlocked) {
      await prefs.setBool('badge_$badgeId', true);
      
      // Update state
      final currentState = state;
      final updatedBadges = (currentState['badges'] as List).map((badge) {
        final badgeMap = Map<String, dynamic>.from(badge);
        if (badgeMap['id'] == badgeId) {
          return {...badgeMap, 'unlocked': true};
        }
        return badgeMap;
      }).toList();
      
      // Add to newly unlocked badges list
      final newlyUnlockedBadges = List<String>.from(currentState['newlyUnlockedBadges'] ?? []);
      newlyUnlockedBadges.add(badgeId);
      
      state = {
        ...currentState,
        'badges': updatedBadges,
        'newlyUnlockedBadges': newlyUnlockedBadges,
      };
    }
  }

  Future<void> completeAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final wasAlreadyCompleted = prefs.getBool('achievement_$achievementId') ?? false;
    
    if (!wasAlreadyCompleted) {
      await prefs.setBool('achievement_$achievementId', true);
      
      // Update state
      final currentState = state;
      final updatedAchievements = (currentState['achievements'] as List).map((achievement) {
        final achievementMap = Map<String, dynamic>.from(achievement);
        if (achievementMap['id'] == achievementId) {
          return {...achievementMap, 'completed': true};
        }
        return achievementMap;
      }).toList();
      
      // Add to newly completed achievements list
      final newlyCompletedAchievements = List<String>.from(currentState['newlyCompletedAchievements'] ?? []);
      newlyCompletedAchievements.add(achievementId);
      
      state = {
        ...currentState,
        'achievements': updatedAchievements,
        'newlyCompletedAchievements': newlyCompletedAchievements,
      };
    }
  }

  Future<void> checkAndAwardBadges(int totalIntake, double goalIntake, DateTime date) async {
    // Load current badge and achievement states
    await _loadBadgeStates();
    
    // Check for first drop badge
    final intakes = WaterIntakeService.getIntakesForDate(date);
    if (intakes.isNotEmpty && !(await _isBadgeUnlocked('first_drop'))) {
      await unlockBadge('first_drop');
    }

    // Check for goal crusher badge
    if (totalIntake >= goalIntake && !(await _isBadgeUnlocked('goal_crusher'))) {
      await unlockBadge('goal_crusher');
      state = {
        ...state,
        'goalReachedToday': true,
      };
    }

    // Check for hydration hero badge
    if (totalIntake >= 3000 && !(await _isBadgeUnlocked('hydration_hero'))) {
      await unlockBadge('hydration_hero');
    }

    // Check for variety seeker badge
    final drinkTypes = WaterIntakeService.getDrinkTypeBreakdownForDate(date);
    if (drinkTypes.length >= 4 && !(await _isBadgeUnlocked('variety_seeker'))) {
      await unlockBadge('variety_seeker');
    }

    // Check for streak badges
    await _checkStreakBadges(date);

    // Check for achievements
    if (totalIntake >= goalIntake && !(await _isAchievementCompleted('goal_achiever'))) {
      await completeAchievement('goal_achiever');
    }

    if (totalIntake >= 3000 && !(await _isAchievementCompleted('hydration_master'))) {
      await completeAchievement('hydration_master');
    }
  }

  Future<void> _checkStreakBadges(DateTime date) async {
    // Calculate current streak
    int currentStreak = 0;
    DateTime checkDate = date;
    
    while (true) {
      final intakes = WaterIntakeService.getIntakesForDate(checkDate);
      if (intakes.isNotEmpty) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Check for streak master badge (7 days)
    if (currentStreak >= 7 && !(await _isBadgeUnlocked('streak_master'))) {
      await unlockBadge('streak_master');
    }

    // Check for consistency king badge (30 days)
    if (currentStreak >= 30 && !(await _isBadgeUnlocked('consistency_king'))) {
      await unlockBadge('consistency_king');
    }
  }

  Future<void> _loadBadgeStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentState = state;
      
      // Update badges with actual unlocked state
      final badges = (currentState['badges'] as List?) ?? [];
      final updatedBadges = badges.map((badge) {
        final badgeMap = Map<String, dynamic>.from(badge);
        final isUnlocked = prefs.getBool('badge_${badgeMap['id']}') ?? false;
        return {...badgeMap, 'unlocked': isUnlocked};
      }).toList();
      
      // Update achievements with actual completed state
      final achievements = (currentState['achievements'] as List?) ?? [];
      final updatedAchievements = achievements.map((achievement) {
        final achievementMap = Map<String, dynamic>.from(achievement);
        final isCompleted = prefs.getBool('achievement_${achievementMap['id']}') ?? false;
        return {...achievementMap, 'completed': isCompleted};
      }).toList();
      
      state = {
        ...currentState,
        'badges': updatedBadges,
        'achievements': updatedAchievements,
      };
    } catch (e) {
      print('Error loading badge states: $e');
    }
  }

  Map<String, dynamic>? getLatestUnlockedBadge() {
    try {
      final newlyUnlockedBadges = List<String>.from(state['newlyUnlockedBadges'] ?? []);
      if (newlyUnlockedBadges.isNotEmpty) {
        final latestBadgeId = newlyUnlockedBadges.last;
        final badges = (state['badges'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
        for (final badge in badges) {
          if (badge['id'] == latestBadgeId) {
            return badge;
          }
        }
      }
    } catch (e) {
      print('Error getting latest unlocked badge: $e');
    }
    return null;
  }

  void clearNewlyUnlockedBadges() {
    state = {
      ...state,
      'newlyUnlockedBadges': <String>[],
    };
  }

  Map<String, dynamic>? getLatestCompletedAchievement() {
    try {
      final newlyCompletedAchievements = List<String>.from(state['newlyCompletedAchievements'] ?? []);
      if (newlyCompletedAchievements.isNotEmpty) {
        final latestAchievementId = newlyCompletedAchievements.last;
        final achievements = (state['achievements'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
        for (final achievement in achievements) {
          if (achievement['id'] == latestAchievementId) {
            return achievement;
          }
        }
      }
    } catch (e) {
      print('Error getting latest completed achievement: $e');
    }
    return null;
  }

  void clearNewlyCompletedAchievements() {
    state = {
      ...state,
      'newlyCompletedAchievements': <String>[],
    };
  }

  void resetGoalReachedToday() {
    state = {
      ...state,
      'goalReachedToday': false,
    };
  }

  // Debug method to force unlock goal crusher badge
  Future<void> forceUnlockGoalCrusher() async {
    await unlockBadge('goal_crusher');
    state = {
      ...state,
      'goalReachedToday': true,
    };
  }

  // Debug method to test badge unlocking
  Future<void> testBadgeUnlocking() async {
    print('Testing badge unlocking...');
    final prefs = await SharedPreferences.getInstance();
    final goalCrusherUnlocked = prefs.getBool('badge_goal_crusher') ?? false;
    print('Goal Crusher badge unlocked: $goalCrusherUnlocked');
    
    if (!goalCrusherUnlocked) {
      print('Unlocking Goal Crusher badge...');
      await unlockBadge('goal_crusher');
      print('Goal Crusher badge unlocked successfully!');
    }
  }
}
