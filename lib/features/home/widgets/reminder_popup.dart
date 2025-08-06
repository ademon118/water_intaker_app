import 'package:flutter/material.dart';

class ReminderPopup extends StatefulWidget {
  final VoidCallback onClose;

  const ReminderPopup({super.key, required this.onClose});

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

  final List<String> _snoozeDurations = ['0.5h', '1h', '1.5h', '2h'];

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
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
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Title
                      const Text(
                        'Reminder',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                            const Text(
                              'Snooze for',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
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
                              onPressed: (_selectedReminderMode >= 0 && _selectedSnoozeDuration >= 0) ? () {
                                // Add reminder logic here
                                _closePopup();
                              } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4D8), // 00B4D8 button color
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
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
                      
                      // Advanced Settings link
                      GestureDetector(
                        onTap: () {
                          // Advanced settings logic here
                        },
                        child: const Text(
                          'Advanced Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF00B4D8), // 00B4D8 blue color
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
              ? Colors.white // White background for selected
              : const Color(0xFFD9D9D9), // D9D9D9 unselected color
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: const Color(0xFF00B4D8), width: 2) // 00B4D8 border for selected
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF00B4D8), // 00B4D8 blue color for all icons
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
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
              ? Colors.white // White background for selected
              : const Color(0xFFD9D9D9), // D9D9D9 unselected color
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: const Color(0xFF00B4D8), width: 2) // 00B4D8 border for selected
              : null,
        ),
        child: Text(
          duration,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
} 