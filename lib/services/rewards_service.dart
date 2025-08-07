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
        'id': 'first_steps',
        'title': 'First Steps',
        'description': 'Add your first drink to start your hydration journey',
        'icon': 'water_drop',
        'completed': false, // Will be updated in checkAndAwardBadges
      },
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
    
    state = {
      ...currentState,
      'badges': updatedBadges,
    };
  }

  Future<void> completeAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
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
    
    state = {
      ...currentState,
      'achievements': updatedAchievements,
    };
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
    if (drinkTypes.length >= 5 && !(await _isBadgeUnlocked('variety_seeker'))) {
      await unlockBadge('variety_seeker');
    }

    // Check for achievements
    if (intakes.isNotEmpty && !(await _isAchievementCompleted('first_steps'))) {
      await completeAchievement('first_steps');
    }

    if (totalIntake >= goalIntake && !(await _isAchievementCompleted('goal_achiever'))) {
      await completeAchievement('goal_achiever');
    }

    if (totalIntake >= 3000 && !(await _isAchievementCompleted('hydration_master'))) {
      await completeAchievement('hydration_master');
    }
  }

  Future<void> _loadBadgeStates() async {
    final prefs = await SharedPreferences.getInstance();
    final currentState = state;
    
    // Update badges with actual unlocked state
    final updatedBadges = (currentState['badges'] as List).map((badge) {
      final badgeMap = Map<String, dynamic>.from(badge);
      final isUnlocked = prefs.getBool('badge_${badgeMap['id']}') ?? false;
      return {...badgeMap, 'unlocked': isUnlocked};
    }).toList();
    
    // Update achievements with actual completed state
    final updatedAchievements = (currentState['achievements'] as List).map((achievement) {
      final achievementMap = Map<String, dynamic>.from(achievement);
      final isCompleted = prefs.getBool('achievement_${achievementMap['id']}') ?? false;
      return {...achievementMap, 'completed': isCompleted};
    }).toList();
    
    state = {
      ...currentState,
      'badges': updatedBadges,
      'achievements': updatedAchievements,
    };
  }

  Map<String, dynamic>? getLatestUnlockedBadge() {
    final badges = (state['badges'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    // Find the most recently unlocked badge (check in reverse order of checking)
    // The badges are checked in this order: first_drop, goal_crusher, hydration_hero, variety_seeker
    // So we check in reverse order to get the most recent one
    for (int i = badges.length - 1; i >= 0; i--) {
      final badge = badges[i];
      if (badge['unlocked'] == true) {
        return badge;
      }
    }
    return null;
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
