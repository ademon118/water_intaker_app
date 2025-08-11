import 'package:flutter/material.dart';
import '../../../services/reminder_service.dart';

class ReminderPopup extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String mode, int snoozeDuration)? onSaveReminder;

  const ReminderPopup({
    super.key, 
    required this.onClose,
    this.onSaveReminder,
  });

  @override
  State<ReminderPopup> createState() => _ReminderPopupState();
}

class _ReminderPopupState extends State<ReminderPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _selectedReminderMode = -1; // -1 = none selected, 0 = Off, 1 = Auto, 2 = Silent
  int _selectedSnoozeDuration = -1; // -1 = none selected, 0 = 0.5h, 1 = 1h, 2 = 1.5h, 3 = 2h

  final List<Map<String, dynamic>> _reminderModes = [
    {
      'name': 'Off',
      'icon': Icons.notifications_off,
    },
    {
      'name': 'Auto',
      'icon': Icons.notifications,
    },
    {
      'name': 'Silent',
      'icon': Icons.volume_off,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closePopup() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4 * _fadeAnimation.value),
          child: Column(
            children: [
              // Transparent area to close popup
              Expanded(
                child: GestureDetector(
                  onTap: _closePopup,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              
              // Popup content
              Transform.translate(
                offset: Offset(0, 100 * _slideAnimation.value),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Title
                      Text(
                        'Reminder',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Reminder mode selection
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildReminderModeButton('Off', Icons.notifications_off, 0),
                            _buildReminderModeButton('Auto', Icons.notifications, 1),
                            _buildReminderModeButton('Silent', Icons.volume_off, 2),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Snooze for section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              'Snooze for',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            // Snooze duration buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSnoozeButton('0.5h', 0),
                                _buildSnoozeButton('1h', 1),
                                _buildSnoozeButton('1.5h', 2),
                                _buildSnoozeButton('2h', 3),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Add button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (_selectedReminderMode >= 0 && _selectedSnoozeDuration >= 0) ? () async {
                              // Request permissions if needed
                              if (_reminderModes[_selectedReminderMode]['name'] != 'Off') {
                                await ReminderService.requestPermissions();
                              }
                              
                              // Add reminder logic here
                              if (widget.onSaveReminder != null) {
                                final selectedMode = _reminderModes[_selectedReminderMode]['name'];
                                final selectedDuration = _selectedSnoozeDuration;
                                await widget.onSaveReminder!(selectedMode, selectedDuration);
                              }
                              _closePopup();
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Test Notification button
                      GestureDetector(
                        onTap: () async {
                          await ReminderService.showTestNotification();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Test notification sent!'),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.fixed,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Test Notification',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Show Pending Reminders button
                      GestureDetector(
                        onTap: () async {
                          final pendingInfo = await ReminderService.getPendingRemindersInfo();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pending reminders: $pendingInfo'),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                duration: const Duration(seconds: 3),
                                behavior: SnackBarBehavior.fixed,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Show Pending Reminders',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Advanced Settings link
                      GestureDetector(
                        onTap: () {
                          // Advanced settings logic here
                        },
                        child: Text(
                          'Advanced Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderModeButton(String name, IconData icon, int index) {
    final isSelected = _selectedReminderMode == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReminderMode = index;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.surface // White background for selected
              : Theme.of(context).colorScheme.surfaceVariant, // D9D9D9 unselected color
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) // 00B4D8 border for selected
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary, // 00B4D8 blue color for all icons
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeButton(String duration, int index) {
    final isSelected = _selectedSnoozeDuration == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSnoozeDuration = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.surface // White background for selected
              : Theme.of(context).colorScheme.surfaceVariant, // D9D9D9 unselected color
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) // 00B4D8 border for selected
              : null,
        ),
        child: Text(
          duration,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
} 