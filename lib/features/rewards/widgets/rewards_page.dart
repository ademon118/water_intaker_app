import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_tokens.dart';
import '../../../services/water_intake_provider.dart';
import '../../../services/rewards_service.dart';
import '../../../services/user_settings_service.dart';
import '../../../services/app_settings_provider.dart';
import '../../../models/user_settings.dart';

class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage> {
  UserSettings? _userSettings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await UserSettingsService.loadSettings();
    setState(() {
      _userSettings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateNotifierProvider);
    final totalIntake = ref.read(waterIntakeNotifierProvider.notifier).getTotalIntakeForDate(selectedDate);
    final userSettings = ref.watch(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    final progress = goalIntake > 0 ? (totalIntake / goalIntake).clamp(0.0, 1.0) : 0.0;
    final rewardsState = ref.watch(rewardsNotifierProvider);
    final badges = (rewardsState['badges'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    final achievements = (rewardsState['achievements'] as List).map((e) => Map<String, dynamic>.from(e)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Section
                    _buildProgressSection(totalIntake, goalIntake, progress),
                    const SizedBox(height: 30),

                    // Badges Section
                    _buildBadgesSection(),
                    const SizedBox(height: 30),

                    // Achievements Section
                    _buildAchievementsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Text(
              'Rewards',
              textAlign: TextAlign.center,
              style: AppTextStyles.inter24Bold.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressSection(int totalIntake, double goalIntake, double progress) {
    final displayTotal = ref.read(appSettingsProvider.notifier).convertToDisplayUnit(totalIntake.toDouble());
    final displayGoal = ref.read(appSettingsProvider.notifier).convertToDisplayUnit(goalIntake);
    final unitLabel = ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: AppTextStyles.inter18Bold.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${displayTotal.toInt()}$unitLabel / ${displayGoal.toInt()}$unitLabel',
                style: AppTextStyles.inter16SemiBold.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            minHeight: 8,
          ),
          const SizedBox(height: 15),
          if (progress >= 1.0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Goal Achieved! 🎉',
                style: AppTextStyles.inter14SemiBold.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    final rewardsState = ref.watch(rewardsNotifierProvider);
    final badges = (rewardsState['badges'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: AppTextStyles.inter20Bold.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _buildBadgeCard(badge);
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final isUnlocked = badge['unlocked'] ?? false;
    
    IconData getIconData(String iconName) {
      switch (iconName) {
        case 'water_drop':
          return Icons.water_drop;
        case 'flag':
          return Icons.flag;
        case 'local_fire_department':
          return Icons.local_fire_department;
        case 'emoji_events':
          return Icons.emoji_events;
        case 'local_bar':
          return Icons.local_bar;
        default:
          return Icons.star;
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              getIconData(badge['icon']),
              color: isUnlocked ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge['name'],
            textAlign: TextAlign.center,
            style: AppTextStyles.inter12SemiBold.copyWith(
              color: isUnlocked
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge['description'],
            textAlign: TextAlign.center,
            style: AppTextStyles.inter10Regular.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final rewardsState = ref.watch(rewardsNotifierProvider);
    final achievements = (rewardsState['achievements'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: AppTextStyles.inter20Bold.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isCompleted = achievement['completed'] ?? false;
    
    IconData getIconData(String iconName) {
      switch (iconName) {
        case 'water_drop':
          return Icons.water_drop;
        case 'flag':
          return Icons.flag;
        case 'local_fire_department':
          return Icons.local_fire_department;
        case 'emoji_events':
          return Icons.emoji_events;
        case 'local_bar':
          return Icons.local_bar;
        default:
          return Icons.star;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isCompleted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              getIconData(achievement['icon']),
              color: isCompleted ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: AppTextStyles.inter16SemiBold.copyWith(
                    color: isCompleted
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: AppTextStyles.inter14Regular.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
        ],
      ),
    );
  }

}
