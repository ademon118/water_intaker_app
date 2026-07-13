import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_tokens.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_toast.dart';
import '../../rewards/widgets/rewards_page.dart';
import '../../settings/widgets/settings_page.dart';
import '../../statistics/widgets/statistics_page.dart';
import 'add_water_popup.dart';
import 'arc_progress_gauge.dart';
import 'reminder_popup.dart';
import 'set_goal_popup.dart';
import '../../rewards/widgets/congratulations_popup.dart';
import '../../../services/user_settings_service.dart';
import '../../../services/reminder_service.dart';
import '../../../services/water_intake_provider.dart';
import '../../../services/rewards_service.dart';
import '../../../services/app_settings_provider.dart';
import '../../../models/water_intake.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  double _currentIntake = 0;
  double _progress = 0.0;
  double _lastGoalIntake = 0;
  bool _showAddWaterPopup = false;
  bool _showReminderPopup = false;
  bool _showSetGoalPopup = false;
  bool _showNavigationDrawer = false;
  bool _hasShownCongratulationsPopup = false;
  Timer? _reminderCountdownTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _reminderCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (ref.read(appSettingsProvider).reminderEnabled) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _reminderCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update progress when dependencies change
    _updateProgressFromDependencies();
  }

  void _updateProgressFromDependencies() {
    final selectedDate = ref.read(selectedDateNotifierProvider);
    final totalIntake = ref.read(waterIntakeNotifierProvider.notifier).getTotalIntakeForDate(selectedDate);
    final userSettings = ref.read(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    
    if (totalIntake != _currentIntake || goalIntake != _lastGoalIntake) {
      final newProgress = goalIntake > 0 ? calculatProgress(totalIntake.toDouble(), goalIntake) : 0.0;
      print('Progress Update: Current: $_currentIntake, Goal: $goalIntake, Progress: $_progress -> $newProgress');
      
      setState(() {
        _currentIntake = totalIntake.toDouble();
        _lastGoalIntake = goalIntake;
        _progress = newProgress;
      });
    }
  }

  double calculatProgress(double current, double goal) {
    if (goal <= 0) return 0.0;
    final progress = current / goal;
    print('Calcul Charts: $current / $goal = $progress');
    return progress.clamp(0.0, 1.0);
  }

  Future<void> _loadData() async {
    try {
      final selectedDate = ref.read(selectedDateNotifierProvider);
      final totalIntake = ref.read(waterIntakeNotifierProvider.notifier).getTotalIntakeForDate(selectedDate);
      final userSettings = ref.read(appSettingsProvider);
      final goalIntake = userSettings.dailyGoal;
      
      final newProgress = goalIntake > 0 ? calculatProgress(totalIntake.toDouble(), goalIntake) : 0.0;
      print('LoadData: Current: $totalIntake, Goal: $goalIntake, Progress: $newProgress');
      
      setState(() {
        _currentIntake = totalIntake.toDouble();
        _lastGoalIntake = goalIntake;
        _progress = newProgress;
      });
    } catch (e) {
      print('Error loading data: $e');
      // Set default values if there's an error
      setState(() {
        _currentIntake = 0.0;
        _lastGoalIntake = 0.0;
        _progress = 0.0;
      });
    }
  }

  Future<void> _addWaterIntake(int amount, String drinkType) async {
    try {
      final selectedDate = ref.read(selectedDateNotifierProvider);
      final intake = WaterIntake(
        date: selectedDate,
        amount: amount,
        drinkType: drinkType,
        timestamp: DateTime.now(),
      );
      
      await ref.read(waterIntakeNotifierProvider.notifier).addWaterIntake(intake);
      await _loadData(); // Reload data to update UI
      
      // Reset the congratulations popup flag when adding new drinks
      setState(() {
        _hasShownCongratulationsPopup = false;
      });
      
      // Check for rewards and badges
      final totalIntake = ref.read(waterIntakeNotifierProvider.notifier).getTotalIntakeForDate(selectedDate);
      final currentGoalIntake = ref.read(appSettingsProvider).dailyGoal;
      
      await ref.read(rewardsNotifierProvider.notifier).checkAndAwardBadges(
        totalIntake, 
        currentGoalIntake, 
        selectedDate,
      );

      _maybeShowCongratulations();
      
      // Show success message
      if (mounted) {
        final displayAmount = ref
            .read(appSettingsProvider.notifier)
            .convertToDisplayUnit(amount.toDouble());
        final unitLabel =
            ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
        
        AppToast.show(
          context,
          message:
              'Added ${displayAmount.toInt()}$unitLabel of $drinkType. Keep hydrating!',
          type: AppToastType.drinkAdded,
        );
      }
    } catch (e) {
      print('Error adding water intake: $e');
      if (mounted) {
        AppToast.show(
          context,
          message: 'Error adding drink. Please try again.',
          type: AppToastType.error,
        );
      }
    }
  }

  void _maybeShowCongratulations() {
    if (!mounted || _hasShownCongratulationsPopup) return;

    final latestBadge =
        ref.read(rewardsNotifierProvider.notifier).getLatestUnlockedBadge();
    final latestAchievement = ref
        .read(rewardsNotifierProvider.notifier)
        .getLatestCompletedAchievement();
    final itemToShow = latestBadge ?? latestAchievement;

    if (itemToShow == null) return;

    _hasShownCongratulationsPopup = true;
    final isBadge = latestBadge != null;
    final displayName = isBadge
        ? (itemToShow['name'] as String?) ?? 'Unknown Badge'
        : (itemToShow['title'] as String?) ?? 'Unknown Achievement';
    final description =
        (itemToShow['description'] as String?) ?? 'No description available';

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CongratulationsPopup(
        badgeName: displayName,
        badgeDescription: description,
        onSave: () {
          if (isBadge) {
            ref.read(rewardsNotifierProvider.notifier).clearNewlyUnlockedBadges();
          } else {
            ref
                .read(rewardsNotifierProvider.notifier)
                .clearNewlyCompletedAchievements();
          }
        },
        onViewBadge: () {
          if (isBadge) {
            ref.read(rewardsNotifierProvider.notifier).clearNewlyUnlockedBadges();
          } else {
            ref
                .read(rewardsNotifierProvider.notifier)
                .clearNewlyCompletedAchievements();
          }
          Navigator.pushNamed(context, '/rewards');
        },
      ),
    ).then((_) {
      if (!mounted) return;
      if (isBadge) {
        ref.read(rewardsNotifierProvider.notifier).clearNewlyUnlockedBadges();
      } else {
        ref
            .read(rewardsNotifierProvider.notifier)
            .clearNewlyCompletedAchievements();
      }
    });
  }

  void _updateProgress() {
    final userSettings = ref.read(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    final newProgress = goalIntake > 0 ? calculatProgress(_currentIntake, goalIntake) : 0.0;
    print('UpdateProgress: Current: $_currentIntake, Goal: $goalIntake, Progress: $_progress -> $newProgress');
    
    setState(() {
      _lastGoalIntake = goalIntake;
      _progress = newProgress;
    });
  }

  Future<void> _saveGoal(double newGoal) async {
    await ref.read(appSettingsProvider.notifier).updateDailyGoal(newGoal);
    // Update progress when goal changes
    _updateProgress();
  }

  Future<void> _saveReminder(String mode, int snoozeDuration) async {
    await UserSettingsService.updateReminderSettings(
      enabled: mode != 'Off',
      mode: mode,
      snoozeDuration: snoozeDuration,
    );
    
    // Schedule actual reminders
    await ReminderService.scheduleReminder(
      mode: mode,
      snoozeDuration: snoozeDuration,
    );
    
    if (mounted) {
      if (mode == 'Off') {
        AppToast.show(
          context,
          message: 'Reminders turned off. You can enable them anytime.',
          type: AppToastType.reminderSet,
        );
      } else {
        final intervalMinutes = _getDurationInMinutes(snoozeDuration);
        AppToast.show(
          context,
          message:
              'Reminder set! Next alert in ${intervalMinutes} minutes.',
          type: AppToastType.reminderSet,
        );
      }
    }
    
    // No need to reload data since we're now watching the provider
  }

  int _getDurationInMinutes(int snoozeDuration) {
    switch (snoozeDuration) {
      case 0: return 15;
      case 1: return 30;
      case 2: return 45;
      case 3: return 60;
      default: return 30;
    }
  }

  DateTime _getNextReminderTime(int intervalMinutes) {
    final now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day, 8, 0);
    
    if (now.isAfter(startTime)) {
      startTime = startTime.add(const Duration(days: 1));
    }
    
    DateTime nextTime = startTime;
    while (nextTime.isBefore(now)) {
      nextTime = nextTime.add(Duration(minutes: intervalMinutes));
    }
    
    return nextTime;
  }

  String _getReminderDisplayValue() {
    if (ref.read(appSettingsProvider) == null || !ref.read(appSettingsProvider).reminderEnabled) {
      return 'Off';
    }

    final intervalMinutes =
        _getDurationInMinutes(ref.read(appSettingsProvider).snoozeDuration);
    final nextReminderTime = _getNextReminderTime(intervalMinutes);
    final now = DateTime.now();
    final difference = nextReminderTime.difference(now);

    if (difference.isNegative) {
      return '${intervalMinutes.toString().padLeft(2, '0')}:00';
    }

    final totalSeconds = difference.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateNotifierProvider);
    final waterIntakes = ref.watch(waterIntakeNotifierProvider);
    final drinkBreakdown = ref.read(waterIntakeNotifierProvider.notifier).getDrinkTypeBreakdownForDate(selectedDate);
    final rewardsState = ref.watch(rewardsNotifierProvider);
    final goalReachedToday = (rewardsState['goalReachedToday'] as bool?) ?? false;
    final userSettings = ref.watch(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const StatisticsPage(),
          const RewardsPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHomeContent() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: _buildProgressCircle()),
                        const SizedBox(height: 20),
                        _buildInfoCards(),
                        const SizedBox(height: 20),
                        _buildTodayDrinks(ref
                            .read(waterIntakeNotifierProvider.notifier)
                            .getDrinkTypeBreakdownForDate(
                                ref.watch(selectedDateNotifierProvider))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_showAddWaterPopup)
            Positioned.fill(
              child: AddWaterPopup(
                onClose: () {
                  setState(() {
                    _showAddWaterPopup = false;
                  });
                },
                onAddWater: _addWaterIntake,
              ),
            ),

          if (_showReminderPopup)
            Positioned.fill(
              child: ReminderPopup(
                onClose: () {
                  setState(() {
                    _showReminderPopup = false;
                  });
                },
                onSaveReminder: _saveReminder,
              ),
            ),

          if (_showSetGoalPopup)
            Positioned.fill(
              child: SetGoalPopup(
                currentGoal: ref.watch(appSettingsProvider).dailyGoal,
                onClose: () {
                  setState(() {
                    _showSetGoalPopup = false;
                  });
                },
                onSaveGoal: _saveGoal,
              ),
            ),
          
          // Navigation Drawer
          if (_showNavigationDrawer)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showNavigationDrawer = false;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNavigationDrawer(),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (_showAddWaterPopup || _showReminderPopup || _showSetGoalPopup) ? null : Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          double fabSize;
          double iconSize;
          
          if (screenWidth < 600) {
            // Mobile
            fabSize = 56;
            iconSize = 30;
          } else if (screenWidth < 1200) {
            // Tablet
            fabSize = 64;
            iconSize = 36;
          } else {
            // Desktop
            fabSize = 72;
            iconSize = 42;
          }
          
          return SizedBox(
            width: fabSize,
            height: fabSize,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showAddWaterPopup = true;
                });
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary, size: iconSize),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = Theme.of(context).colorScheme;
    final horizontalPadding = screenWidth < 600 ? 20.0 : 30.0;
    final iconSize = screenWidth < 600 ? 24.0 : 28.0;
    final fontSize = screenWidth < 600 ? 18.0 : 20.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showNavigationDrawer = true),
            child: Icon(Icons.menu, color: colors.onSurface, size: iconSize),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: ref.read(selectedDateNotifierProvider),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: colors.primary,
                        onPrimary: colors.onPrimary,
                        surface: colors.surface,
                        onSurface: colors.onSurface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null &&
                  picked != ref.read(selectedDateNotifierProvider)) {
                ref.read(selectedDateNotifierProvider.notifier).setDate(picked);
                ref
                    .read(waterIntakeNotifierProvider.notifier)
                    .loadIntakesForDate(picked);
                await _loadData();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDateText(),
                  style: AppTextStyles.interSemiBold(
                    fontSize,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: colors.onSurfaceVariant,
                  size: iconSize * 0.9,
                ),
              ],
            ),
          ),
          const Spacer(),
          Icon(Icons.grid_view, color: colors.onSurface, size: iconSize),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final userSettings = ref.watch(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    final colors = Theme.of(context).colorScheme;
    final unit = ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
    final intake = ref
        .read(appSettingsProvider.notifier)
        .convertToDisplayUnit(_currentIntake)
        .toInt();
    final goal = ref
        .read(appSettingsProvider.notifier)
        .convertToDisplayUnit(goalIntake)
        .toInt();

    final gaugeSize = screenWidth < 600
        ? screenWidth * 0.62
        : screenWidth < 1200
            ? screenWidth * 0.38
            : screenWidth * 0.24;

    return ArcProgressGauge(
      progress: _progress,
      size: gaugeSize,
      strokeWidth: gaugeSize * 0.11,
      trackColor: const Color(0xFFE8EEF5),
      progressColor: colors.primary,
      intakeText: '$intake$unit',
      goalText: '/$goal$unit',
      centerChild: AppSvg(
        AppAssets.waterDrop,
        width: gaugeSize * 0.32,
        height: gaugeSize * 0.32,
      ),
    );
  }

  Widget _buildInfoCards() {
    final userSettings = ref.watch(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showReminderPopup = true),
            child: _buildInfoCard(
              title: 'Reminder',
              value: _getReminderDisplayValue(),
              asset: AppAssets.reminder,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showSetGoalPopup = true),
            child: _buildInfoCard(
              title: 'Goal',
              value:
                  '${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(goalIntake).toInt()}',
              asset: AppAssets.target,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String asset,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.interMedium(14).copyWith(
                    color: AppColors.black70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyles.interBold(28).copyWith(
                    color: AppColors.black1,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F4FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppSvg(asset, width: 20, height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayDrinks(Map<String, int> drinkBreakdown) {
    final drinkEntries = drinkBreakdown.entries.toList();
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today Drinks',
          style: AppTextStyles.inter20Bold.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: drinkEntries.isNotEmpty
              ? SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: drinkEntries.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final entry = drinkEntries[index];
                      final amount =
                          '${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(entry.value.toDouble()).toInt()}${ref.read(appSettingsProvider.notifier).getUnitAbbreviation()}';
                      return _buildDrinkCard(
                        drinkType: entry.key,
                        name: entry.key,
                        amount: amount,
                      );
                    },
                  ),
                )
              : _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildDrinkCard({
    required String drinkType,
    required String name,
    required String amount,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSvg(
            AppAssets.drinkAssetFor(drinkType),
            width: 36,
            height: 36,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.inter14SemiBold.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTextStyles.inter12Medium
                .copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          AppSvg(AppAssets.drinkWater, width: 40, height: 40),
          const SizedBox(height: 12),
          Text(
            'No drinks yet today',
            style: AppTextStyles.inter14Regular
                .copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _getDateText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = ref.read(selectedDateNotifierProvider);
    final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      // Format: "Jan 15" or "Dec 25"
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[selectedDate.month - 1]} ${selectedDate.day}';
    }
  }

  Widget _buildNavigationDrawer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final userSettings = ref.watch(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    final colors = Theme.of(context).colorScheme;
    
    // Responsive drawer width
    double drawerWidth;
    if (screenWidth < 600) {
      // Mobile - 75% of screen width
      drawerWidth = screenWidth * 0.75;
    } else if (screenWidth < 1200) {
      // Tablet - 50% of screen width
      drawerWidth = screenWidth * 0.5;
    } else {
      // Desktop - 400px max width
      drawerWidth = 400;
    }
    
    final topInset = MediaQuery.of(context).padding.top;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: drawerWidth,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Material(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                color: colors.primary,
                padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showNavigationDrawer = false;
                        });
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: colors.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.onPrimary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: AppSvg(
                          AppAssets.drawerProfile,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Goal',
                            style: AppTextStyles.inter18Bold
                                .copyWith(color: colors.onPrimary),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.onPrimary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: colors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${goalIntake.toInt()}ml',
                                  style: AppTextStyles.inter14SemiBold
                                      .copyWith(color: colors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: colors.surface,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        _buildNavigationItem(
                          'Home',
                          AppAssets.drawerHome,
                          true,
                          () {
                            setState(() {
                              _showNavigationDrawer = false;
                              _currentIndex = 0;
                            });
                          },
                        ),
                        _buildNavigationItem(
                          'Dashboard',
                          AppAssets.drawerDashboard,
                          false,
                          () => setState(() => _showNavigationDrawer = false),
                        ),
                        _buildNavigationItem(
                          'Reminders',
                          AppAssets.drawerReminder,
                          false,
                          () {
                            setState(() {
                              _showNavigationDrawer = false;
                              _showReminderPopup = true;
                            });
                          },
                        ),
                        _buildNavigationItem(
                          'Achievements',
                          AppAssets.drawerAchievements,
                          false,
                          () {
                            setState(() {
                              _showNavigationDrawer = false;
                              _currentIndex = 2;
                            });
                          },
                        ),
                        _buildNavigationItem(
                          'Health Care Tips',
                          AppAssets.drawerHealthTips,
                          false,
                          () => setState(() => _showNavigationDrawer = false),
                        ),
                        _buildNavigationItem(
                          'Profile',
                          AppAssets.drawerProfile,
                          false,
                          () => setState(() => _showNavigationDrawer = false),
                        ),
                        _buildNavigationItem(
                          'Setting',
                          AppAssets.drawerSettings,
                          false,
                          () {
                            setState(() {
                              _showNavigationDrawer = false;
                              _currentIndex = 3;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    String title,
    String asset,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: colors.primary, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                AppSvg(asset, width: 24, height: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: (isSelected
                          ? AppTextStyles.inter16SemiBold
                          : AppTextStyles.inter16Medium)
                      .copyWith(color: colors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    Widget navItem({
      required int index,
      required String label,
      required String asset,
    }) {
      final selected = _currentIndex == index;
      final tint = selected ? colors.primary : colors.onSurfaceVariant;

      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSvg(asset, width: 24, height: 24, color: tint),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: (selected
                          ? AppTextStyles.inter12SemiBold
                          : AppTextStyles.inter12Regular)
                      .copyWith(color: tint),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 8 + bottomInset),
        child: Row(
          children: [
            navItem(index: 0, label: 'Home', asset: AppAssets.navHome),
            navItem(
              index: 1,
              label: 'Statistics',
              asset: AppAssets.navStatistics,
            ),
            navItem(index: 2, label: 'Rewards', asset: AppAssets.navRewards),
            navItem(index: 3, label: 'Setting', asset: AppAssets.navSettings),
          ],
        ),
      ),
    );
  }
}
