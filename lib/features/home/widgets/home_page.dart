import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dashboard/widgets/dashboard_page.dart';
import '../../rewards/widgets/rewards_page.dart';
import '../../settings/widgets/settings_page.dart';
import '../../statistics/widgets/statistics_page.dart';
import 'add_water_popup.dart';
import 'reminder_popup.dart';
import 'set_goal_popup.dart';
import '../../rewards/widgets/congratulations_popup.dart';
import '../../../services/water_intake_service.dart';
import '../../../services/user_settings_service.dart';
import '../../../services/reminder_service.dart';
import '../../../services/water_intake_provider.dart';
import '../../../services/rewards_service.dart';
import '../../../services/app_settings_provider.dart';
import '../../../models/water_intake.dart';
import '../../../models/user_settings.dart';

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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      
      // Show success message
      if (mounted) {
        final unit = ref.read(appSettingsProvider).unit;
        final displayAmount = ref.read(appSettingsProvider.notifier).convertToDisplayUnit(amount.toDouble());
        final unitLabel = ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${displayAmount.toInt()}$unitLabel of $drinkType'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error adding water intake: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error adding drink. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
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
    
    // Show success message with next reminder time
    if (mounted && mode != 'Off') {
      final intervalMinutes = _getDurationInMinutes(snoozeDuration);
      final nextReminderTime = _getNextReminderTime(intervalMinutes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminders set! Next reminder in ${intervalMinutes} minutes'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    
    // No need to reload data since we're now watching the provider
  }

  int _getDurationInMinutes(int snoozeDuration) {
    switch (snoozeDuration) {
      case 0: return 30; // 0.5h = 30 minutes
      case 1: return 60; // 1h = 60 minutes
      case 2: return 90; // 1.5h = 90 minutes
      case 3: return 120; // 2h = 120 minutes
      default: return 60;
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
    
    final intervalMinutes = ref.read(appSettingsProvider).snoozeDuration;
    final nextReminderTime = _getNextReminderTime(intervalMinutes);
    final now = DateTime.now();
    final difference = nextReminderTime.difference(now);
    
    if (difference.isNegative) {
      return '${intervalMinutes}m';
    }
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
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
    

    


                // Show congratulations popup for any newly unlocked badge or completed achievement
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final latestBadge = ref.read(rewardsNotifierProvider.notifier).getLatestUnlockedBadge();
              final latestAchievement = ref.read(rewardsNotifierProvider.notifier).getLatestCompletedAchievement();
              
              if ((latestBadge != null || latestAchievement != null) && mounted && !_hasShownCongratulationsPopup) {
                setState(() {
                  _hasShownCongratulationsPopup = true;
                });
                // Add a small delay to ensure the UI is fully updated
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    // Show badge popup if available, otherwise show achievement popup
                    final itemToShow = latestBadge ?? latestAchievement;
                    final isBadge = latestBadge != null;
                    
                    if (itemToShow != null) {
                      // Get the correct name/title based on whether it's a badge or achievement
                      final displayName = isBadge 
                          ? (itemToShow['name'] as String?) ?? 'Unknown Badge'
                          : (itemToShow['title'] as String?) ?? 'Unknown Achievement';
                      
                      final description = (itemToShow['description'] as String?) ?? 'No description available';
                      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CongratulationsPopup(
                          badgeName: displayName,
                          badgeDescription: description,
                          onSave: () {
                            if (isBadge) {
                              ref.read(rewardsNotifierProvider.notifier).clearNewlyUnlockedBadges();
                            } else {
                              ref.read(rewardsNotifierProvider.notifier).clearNewlyCompletedAchievements();
                            }
                          },
                          onViewBadge: () {
                            if (isBadge) {
                              ref.read(rewardsNotifierProvider.notifier).clearNewlyUnlockedBadges();
                            } else {
                              ref.read(rewardsNotifierProvider.notifier).clearNewlyCompletedAchievements();
                            }
                            Navigator.pushNamed(context, '/rewards');
                          },
                        ),
                      );
                    }
                  }
                });
              }
            });



    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
          // Main content with dimming effect
          Opacity(
            opacity: (_showAddWaterPopup || _showReminderPopup || _showSetGoalPopup || _showNavigationDrawer) ? 0.3 : 1.0,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProgressCircle(),
                          const SizedBox(height: 20),
                          _buildInfoCards(),
                          const SizedBox(height: 20),
                          _buildTodayDrinks(ref.read(waterIntakeNotifierProvider.notifier).getDrinkTypeBreakdownForDate(ref.watch(selectedDateNotifierProvider))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add Water Popup
          if (_showAddWaterPopup)
            AddWaterPopup(
              onClose: () {
                setState(() {
                  _showAddWaterPopup = false;
                });
              },
              onAddWater: _addWaterIntake,
            ),
          
          // Reminder Popup
          if (_showReminderPopup)
            ReminderPopup(
              onClose: () {
                setState(() {
                  _showReminderPopup = false;
                });
              },
              onSaveReminder: _saveReminder,
            ),
          
          // Set Goal Popup
          if (_showSetGoalPopup)
            SetGoalPopup(
              currentGoal: ref.watch(appSettingsProvider).dailyGoal,
              onClose: () {
                setState(() {
                  _showSetGoalPopup = false;
                });
              },
              onSaveGoal: _saveGoal,
            ),
          
          // Navigation Drawer
          if (_showNavigationDrawer)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showNavigationDrawer = false;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    _buildNavigationDrawer(),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
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
    
    // Responsive sizing
    double horizontalPadding;
    double verticalPadding;
    double iconSize;
    double fontSize;
    double spacing;
    
    if (screenWidth < 600) {
      // Mobile
      horizontalPadding = 20;
      verticalPadding = 15;
      iconSize = 24;
      fontSize = 18;
      spacing = 15;
    } else if (screenWidth < 1200) {
      // Tablet
      horizontalPadding = 30;
      verticalPadding = 20;
      iconSize = 28;
      fontSize = 20;
      spacing = 20;
    } else {
      // Desktop
      horizontalPadding = 40;
      verticalPadding = 25;
      iconSize = 32;
      fontSize = 24;
      spacing = 25;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        children: [
          // Hamburger menu icon
          GestureDetector(
            onTap: () {
              setState(() {
                _showNavigationDrawer = true;
              });
            },
            child: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: iconSize),
          ),
          
          SizedBox(width: spacing),
          
          // Test notification button
          GestureDetector(
            onTap: () async {
              await ReminderService.showTestNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Test notification sent!'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(iconSize * 0.33),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.onPrimary,
                size: iconSize * 0.83,
              ),
            ),
          ),

          const Spacer(),

          // Today text with dropdown arrow (centered)
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
                        primary: Theme.of(context).colorScheme.primary,
                        onPrimary: Theme.of(context).colorScheme.onPrimary,
                        surface: Theme.of(context).colorScheme.surface,
                        onSurface: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
                             if (picked != null && picked != ref.read(selectedDateNotifierProvider)) {
                 ref.read(selectedDateNotifierProvider.notifier).setDate(picked);
                 ref.read(waterIntakeNotifierProvider.notifier).loadIntakesForDate(picked);
                 // Reload data and update progress for the new date
                 await _loadData();
               }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDateText(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: spacing * 0.53),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  size: iconSize * 0.83,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Grid icon
          Icon(Icons.grid_view, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: iconSize),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final userSettings = ref.watch(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    
    // Responsive sizing based on screen size
    double containerSize;
    double circleSize;
    double iconSize;
    double fontSize;
    double subFontSize;
    
    if (screenWidth < 600) {
      // Mobile
      containerSize = screenWidth * 0.7;
      circleSize = containerSize * 0.88;
      iconSize = containerSize * 0.24;
      fontSize = 24;
      subFontSize = 16;
    } else if (screenWidth < 1200) {
      // Tablet
      containerSize = screenWidth * 0.4;
      circleSize = containerSize * 0.88;
      iconSize = containerSize * 0.24;
      fontSize = 28;
      subFontSize = 18;
    } else {
      // Desktop
      containerSize = screenWidth * 0.25;
      circleSize = containerSize * 0.88;
      iconSize = containerSize * 0.24;
      fontSize = 32;
      subFontSize = 20;
    }
    
    return Center(
      child: Container(
        width: containerSize,
        height: containerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress Circle with exact colors from Figma
            SizedBox(
              width: circleSize,
              height: circleSize,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: circleSize * 0.14,
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // Debug info (remove in production)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'P: ${_progress.toStringAsFixed(3)}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),

            // Center Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Water Drop Icon with Ripple Effect
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary, // 00B4D8 for water drop
                    borderRadius: BorderRadius.circular(iconSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: iconSize * 0.5,
                  ),
                ),
                SizedBox(height: iconSize * 0.25),

                // Intake Text
                Text(
                  '${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(_currentIntake).toInt()}${ref.read(appSettingsProvider.notifier).getUnitAbbreviation()}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '/${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(goalIntake).toInt()}${ref.read(appSettingsProvider.notifier).getUnitAbbreviation()}',
                  style: TextStyle(fontSize: subFontSize, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                // Debug info (remove in production)
                // Text(
                //   'Raw: ${_currentIntake.toInt()}/${goalIntake.toInt()}',
                //   style: TextStyle(fontSize: 10, color: Colors.red),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final userSettings = ref.watch(appSettingsProvider);
    final goalIntake = userSettings.dailyGoal;
    
    // Responsive layout based on screen size
    if (screenWidth < 600) {
      // Mobile - Stack vertically
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showReminderPopup = true;
              });
            },
            child: _buildInfoCard(
              title: 'Reminder',
              value: _getReminderDisplayValue(),
              icon: Icons.notifications,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSetGoalPopup = true;
              });
            },
            child: _buildInfoCard(
              title: 'Goal',
              value: '${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(goalIntake).toInt()}${ref.read(appSettingsProvider.notifier).getUnitAbbreviation()}',
              icon: Icons.track_changes,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      );
    } else {
      // Tablet and Desktop - Side by side
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showReminderPopup = true;
                });
              },
                          child: _buildInfoCard(
              title: 'Reminder',
              value: _getReminderDisplayValue(),
              icon: Icons.notifications,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            ),
          ),
          SizedBox(width: screenWidth < 1200 ? 15 : 20),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showSetGoalPopup = true;
                });
              },
              child: _buildInfoCard(
                title: 'Goal',
                value: '${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(goalIntake).toInt()}${ref.read(appSettingsProvider.notifier).getUnitAbbreviation()}',
                icon: Icons.track_changes,
                iconColor: Theme.of(context).colorScheme.primary,
            ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    double padding;
    double titleFontSize;
    double valueFontSize;
    double iconSize;
    double iconContainerSize;
    
    if (screenWidth < 600) {
      // Mobile
      padding = 16;
      titleFontSize = 14;
      valueFontSize = 22;
      iconSize = 18;
      iconContainerSize = 36;
    } else if (screenWidth < 1200) {
      // Tablet
      padding = 20;
      titleFontSize = 16;
      valueFontSize = 26;
      iconSize = 20;
      iconContainerSize = 40;
    } else {
      // Desktop
      padding = 24;
      titleFontSize = 18;
      valueFontSize = 30;
      iconSize = 22;
      iconContainerSize = 44;
    }
    
    return Container(
      padding: EdgeInsets.all(padding),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: titleFontSize, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                SizedBox(height: padding * 0.25),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(iconContainerSize / 2),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayDrinks(Map<String, int> drinkBreakdown) {
    final drinkEntries = drinkBreakdown.entries.toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today Drinks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        Container(
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
          child: drinkEntries.isNotEmpty 
              ? _buildDrinkCardsGrid(drinkEntries)
              : _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildDrinkCardsGrid(List<MapEntry<String, int>> drinkEntries) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive grid configuration
    int crossAxisCount;
    double childAspectRatio;
    double spacing;
    
    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 1.4;
      spacing = 10;
    } else if (screenWidth < 1200) {
      // Tablet
      crossAxisCount = 3;
      childAspectRatio = 1.3;
      spacing = 15;
    } else {
      // Desktop
      crossAxisCount = 4;
      childAspectRatio = 1.2;
      spacing = 20;
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: drinkEntries.length,
        itemBuilder: (context, index) {
          final entry = drinkEntries[index];
          return _buildDrinkCard(
            icon: _getDrinkIcon(entry.key),
            name: entry.key,
            amount: '${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(entry.value.toDouble()).toInt()}${ref.read(appSettingsProvider.notifier).getUnitAbbreviation()}',
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use the same responsive grid configuration as drink cards
    int crossAxisCount;
    double childAspectRatio;
    double spacing;
    
    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 1.4;
      spacing = 10;
    } else if (screenWidth < 1200) {
      // Tablet
      crossAxisCount = 3;
      childAspectRatio = 1.3;
      spacing = 15;
    } else {
      // Desktop
      crossAxisCount = 4;
      childAspectRatio = 1.2;
      spacing = 20;
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: 1, // Single empty card
        itemBuilder: (context, index) {
          return _buildEmptyCard();
        },
      ),
    );
  }

  Widget _buildEmptyCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use the same responsive sizing as drink cards
    double padding;
    double iconSize;
    double nameFontSize;
    double amountFontSize;
    double spacing;
    
    if (screenWidth < 600) {
      // Mobile
      padding = 12;
      iconSize = 32;
      nameFontSize = 14;
      amountFontSize = 12;
      spacing = 8;
    } else if (screenWidth < 1200) {
      // Tablet
      padding = 15;
      iconSize = 36;
      nameFontSize = 16;
      amountFontSize = 14;
      spacing = 10;
    } else {
      // Desktop
      padding = 18;
      iconSize = 40;
      nameFontSize = 18;
      amountFontSize = 16;
      spacing = 12;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding * 0.75),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.water_drop,
            size: iconSize,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: spacing),
          Flexible(
            child: Text(
              'No drinks today',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: spacing * 0.5),
          Flexible(
            child: Text(
              'Tap + to add',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: amountFontSize,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDrinkIcon(String drinkType) {
    switch (drinkType.toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'coffee':
        return FontAwesomeIcons.coffee;
      case 'tea':
        return FontAwesomeIcons.mugHot;
      case 'milk':
        return FontAwesomeIcons.mugSaucer;
      case 'smoothie':
        return FontAwesomeIcons.blender;
      case 'juice':
        return FontAwesomeIcons.wineGlass;
      default:
        return Icons.local_bar;
    }
  }

  Widget _buildDrinkCard({
    required IconData icon,
    required String name,
    required String amount,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    double padding;
    double iconSize;
    double nameFontSize;
    double amountFontSize;
    double spacing;
    
    if (screenWidth < 600) {
      // Mobile
      padding = 12;
      iconSize = 32;
      nameFontSize = 14;
      amountFontSize = 12;
      spacing = 8;
    } else if (screenWidth < 1200) {
      // Tablet
      padding = 15;
      iconSize = 36;
      nameFontSize = 16;
      amountFontSize = 14;
      spacing = 10;
    } else {
      // Desktop
      padding = 18;
      iconSize = 40;
      nameFontSize = 18;
      amountFontSize = 16;
      spacing = 12;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding * 0.75),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: iconSize),
          SizedBox(height: spacing),
          Flexible(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: spacing * 0.5),
          Flexible(
            child: Text(
              amount, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: amountFontSize, 
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: drawerWidth,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Section with Blue Background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Back Arrow and User Section
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showNavigationDrawer = false;
                          });
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // User Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Goal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Goal Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${goalIntake.toInt()}ml',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Navigation Items
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    _buildNavigationItem('Home', Icons.home, true, () {}),
                    _buildNavigationItem('Dashboard', Icons.dashboard, false, () {}),
                    _buildNavigationItem('Reminders', Icons.notifications, false, () {}),
                    _buildNavigationItem('Achievements', Icons.star, false, () {}),
                    _buildNavigationItem('Health Care Tips', Icons.lightbulb, false, () {}),
                    _buildNavigationItem('Profile', Icons.person, false, () {}),
                    _buildNavigationItem('Setting', Icons.settings, false, () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(String title, IconData icon, bool isSelected, VoidCallback onTap) {
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
              color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    
    // Responsive sizing
    double iconSize;
    double fontSize;
    
    if (screenWidth < 600) {
      // Mobile
      iconSize = 24;
      fontSize = 12;
    } else if (screenWidth < 1200) {
      // Tablet
      iconSize = 28;
      fontSize = 14;
    } else {
      // Desktop
      iconSize = 32;
      fontSize = 16;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ?? theme.colorScheme.primary,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ?? theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: fontSize,
          color: theme.bottomNavigationBarTheme.selectedItemColor ?? theme.colorScheme.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400, 
          fontSize: fontSize,
          color: theme.bottomNavigationBarTheme.unselectedItemColor ?? theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: iconSize), 
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: iconSize),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star, size: iconSize), 
            label: 'Rewards'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: iconSize), 
            label: 'Setting'
          ),
        ],
      ),
    );
  }
} 