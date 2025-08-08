import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dashboard/widgets/dashboard_page.dart';
import '../../rewards/widgets/rewards_page.dart';
import 'add_water_popup.dart';
import 'reminder_popup.dart';
import 'set_goal_popup.dart';
import '../../../services/water_intake_service.dart';
import '../../../services/user_settings_service.dart';
import '../../../services/reminder_service.dart';
import '../../../services/water_intake_provider.dart';
import '../../../services/rewards_service.dart';
import '../../../models/water_intake.dart';
import '../../../models/user_settings.dart';
import '../../rewards/widgets/congratulations_popup.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  double _currentIntake = 0;
  double _goalIntake = 2800;
  double _progress = 0.0;
  bool _showAddWaterPopup = false;
  bool _showReminderPopup = false;
  bool _showSetGoalPopup = false;
  bool _showNavigationDrawer = false;
  bool _hasShownCongratulationsPopup = false;
  UserSettings? _userSettings;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final settings = await UserSettingsService.loadSettings();
      final selectedDate = ref.read(selectedDateNotifierProvider);
      final totalIntake = ref.read(waterIntakeNotifierProvider.notifier).getTotalIntakeForDate(selectedDate);
      
      setState(() {
        _userSettings = settings;
        _goalIntake = settings.dailyGoal;
        _currentIntake = totalIntake.toDouble();
        _progress = _goalIntake > 0 ? (_currentIntake / _goalIntake).clamp(0.0, 1.0) : 0.0;
      });
    } catch (e) {
      print('Error loading data: $e');
      // Set default values if there's an error
      setState(() {
        _goalIntake = 2800.0;
        _currentIntake = 0.0;
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
      final goalIntake = _userSettings?.dailyGoal ?? 2800;
      
      await ref.read(rewardsNotifierProvider.notifier).checkAndAwardBadges(
        totalIntake, 
        goalIntake, 
        selectedDate,
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${amount}ml of $drinkType'),
            backgroundColor: const Color(0xFF00B4D8),
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
            backgroundColor: Colors.red,
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

  Future<void> _saveGoal(double newGoal) async {
    await UserSettingsService.updateDailyGoal(newGoal);
    await _loadData(); // Reload data to update UI
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
    
    await _loadData(); // Reload data to update UI
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateNotifierProvider);
    final waterIntakes = ref.watch(waterIntakeNotifierProvider);
    final drinkBreakdown = ref.read(waterIntakeNotifierProvider.notifier).getDrinkTypeBreakdownForDate(selectedDate);
    final rewardsState = ref.watch(rewardsNotifierProvider);
    final goalReachedToday = (rewardsState['goalReachedToday'] as bool?) ?? false;
    
    // Update current intake and progress when data changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final totalIntake = ref.read(waterIntakeNotifierProvider.notifier).getTotalIntakeForDate(selectedDate);
      if (totalIntake != _currentIntake) {
        setState(() {
          _currentIntake = totalIntake.toDouble();
          _progress = _goalIntake > 0 ? (_currentIntake / _goalIntake).clamp(0.0, 1.0) : 0.0;
        });
      }
    });

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
      backgroundColor: const Color(0xFFF1F5F9), // F1F5F9 for overall background
      body: Stack(
        children: [
                  // Main content with dimming effect
        Opacity(
          opacity: (_showAddWaterPopup || _showReminderPopup || _showSetGoalPopup || _showNavigationDrawer) ? 0.3 : 1.0, // Dim background when popup is shown
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 20 : 30),
                      child: Column(
                        children: [
                          // Progress Circle
                          _buildProgressCircle(),
                          SizedBox(height: MediaQuery.of(context).size.width < 600 ? 30 : 40),

                          // Info Cards
                          _buildInfoCards(),
                          SizedBox(height: MediaQuery.of(context).size.width < 600 ? 30 : 40),

                          // Today Drinks
                          _buildTodayDrinks(drinkBreakdown),
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
              currentGoal: _goalIntake,
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

      // Floating Action Button (hidden when popup is active)
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
              backgroundColor: const Color(0xFF00B4D8), // 00B4D8 for FAB
              child: Icon(Icons.add, color: Colors.white, size: iconSize),
            ),
          );
        },
      ),

      // Bottom Navigation (hidden when popup is active)
      bottomNavigationBar: (_showAddWaterPopup || _showReminderPopup || _showSetGoalPopup) ? null : _buildBottomNavigation(),
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
            child: Icon(Icons.menu, color: Colors.grey[600], size: iconSize),
          ),
          
          SizedBox(width: spacing),
          
          // Test notification button
          GestureDetector(
            onTap: () async {
              await ReminderService.showTestNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent!'),
                    backgroundColor: Color(0xFF00B4D8),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(iconSize * 0.33),
              decoration: BoxDecoration(
                color: const Color(0xFF00B4D8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications,
                color: Colors.white,
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
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF00B4D8), // 00B4D8 for primary color
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
                             if (picked != null && picked != ref.read(selectedDateNotifierProvider)) {
                 ref.read(selectedDateNotifierProvider.notifier).setDate(picked);
                 ref.read(waterIntakeNotifierProvider.notifier).loadIntakesForDate(picked);
                 await _loadData(); // Reload data for the new date
               }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDateText(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: spacing * 0.53),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: iconSize * 0.83,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Grid icon
          Icon(Icons.grid_view, color: Colors.grey[600], size: iconSize),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
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
    
    return Container(
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
              backgroundColor: const Color(0xFFD9D9D9), // D9D9D9 for circle background
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00B4D8), // 00B4D8 for filled circle
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
                  color: const Color(0xFF00B4D8), // 00B4D8 for water drop
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B4D8).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: iconSize * 0.5,
                ),
              ),
              SizedBox(height: iconSize * 0.25),

              // Intake Text
              Text(
                '${_currentIntake.toInt()}ml',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '/${_goalIntake.toInt()}ml',
                style: TextStyle(fontSize: subFontSize, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    
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
              value: '59:30',
              icon: Icons.notifications,
              iconColor: const Color(0xFFFFFFFF), // FFFFFF for remainder
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
              value: '${_goalIntake.toInt()}',
              icon: Icons.track_changes,
              iconColor: const Color(0xFFFFFFFF), // FFFFFF for goal
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
                value: '59:30',
                icon: Icons.notifications,
                iconColor: const Color(0xFFFFFFFF), // FFFFFF for remainder
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
                value: '${_goalIntake.toInt()}',
                icon: Icons.track_changes,
                iconColor: const Color(0xFFFFFFFF), // FFFFFF for goal
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
        color: const Color(0xFFFFFFFF), // FFFFFF for card background
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  style: TextStyle(fontSize: titleFontSize, color: Colors.grey[600]),
                ),
                SizedBox(height: padding * 0.25),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
              color: const Color(0xFF000000), // 000000 for icon color
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
        const Text(
          'Today Drinks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF), // FFFFFF for container background
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
            amount: '${entry.value}ml',
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No drinks today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the + button to add your first drink',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
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
        color: const Color(0xFFA2D2FF), // A2D2FF for today drinks background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF000000), size: iconSize), // 000000 for icon color
          SizedBox(height: spacing),
          Flexible(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000), // 000000 for text color
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
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w500,
              ), // 000000 for amount text
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Section with Blue Background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF00B4D8), // Blue background
                borderRadius: BorderRadius.only(
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // User Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Goal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Goal Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_goalIntake.toInt()}ml',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
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
              color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent, // Light blue for selected
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                  ? Border.all(color: const Color(0xFF00B4D8), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black,
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate to Dashboard when Statistics is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          } else if (index == 2) {
            // Navigate to Rewards page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RewardsPage()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: fontSize),
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