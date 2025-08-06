import 'package:flutter/material.dart';
import '../../dashboard/widgets/dashboard_page.dart';
import 'add_water_popup.dart';
import 'reminder_popup.dart';
import 'set_goal_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  double _currentIntake = 2100;
  double _goalIntake = 2800;
  double _progress = 0.75; // 2100/2800 = 0.75
  bool _showAddWaterPopup = false;
  bool _showReminderPopup = false;
  bool _showSetGoalPopup = false;
  DateTime _selectedDate = DateTime.now();
  bool _showNavigationDrawer = false;

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Progress Circle
                          _buildProgressCircle(),
                          const SizedBox(height: 30),

                          // Info Cards
                          _buildInfoCards(),
                          const SizedBox(height: 30),

                          // Today Drinks
                          _buildTodayDrinks(),
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
            ),
          
          // Reminder Popup
          if (_showReminderPopup)
            ReminderPopup(
              onClose: () {
                setState(() {
                  _showReminderPopup = false;
                });
              },
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
      floatingActionButton: (_showAddWaterPopup || _showReminderPopup || _showSetGoalPopup) ? null : FloatingActionButton(
        onPressed: () {
          setState(() {
            _showAddWaterPopup = true;
          });
        },
        backgroundColor: const Color(0xFF00B4D8), // 00B4D8 for FAB
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      // Bottom Navigation (hidden when popup is active)
      bottomNavigationBar: (_showAddWaterPopup || _showReminderPopup || _showSetGoalPopup) ? null : _buildBottomNavigation(),
    );
  }

    Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Hamburger menu icon
          GestureDetector(
            onTap: () {
              setState(() {
                _showNavigationDrawer = true;
              });
            },
            child: Icon(Icons.menu, color: Colors.grey[600], size: 24),
          ),

          const Spacer(),

          // Today text with dropdown arrow (centered)
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
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
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDateText(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Grid icon
          Icon(Icons.grid_view, color: Colors.grey[600], size: 24),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Container(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Circle with exact colors from Figma
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 30,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4D8), // 00B4D8 for water drop
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B4D8).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 15),

              // Intake Text
              Text(
                '${_currentIntake.toInt()}ml',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '/${_goalIntake.toInt()}ml',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
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
        const SizedBox(width: 15),
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

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF000000), // 000000 for icon color
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayDrinks() {
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
          child: Row(
            children: [
              Expanded(
                child: _buildDrinkCard(
                  icon: Icons.local_drink,
                  name: 'Milk',
                  amount: '300ml',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDrinkCard(
                  icon: Icons.local_bar,
                  name: 'Water',
                  amount: '300ml',
                ),
              ),
              // Add empty space to the right as shown in the design
              const SizedBox(width: 15),
              Expanded(
                child: Container(), // Empty space for potential third card
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrinkCard({
    required IconData icon,
    required String name,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFA2D2FF), // A2D2FF for today drinks background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF000000), size: 35), // 000000 for icon color, larger size
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF000000), // 000000 for text color
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, 
              color: const Color(0xFF000000),
              fontWeight: FontWeight.w500,
            ), // 000000 for amount text
          ),
        ],
      ),
    );
  }

  String _getDateText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
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
      return '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
    }
  }

  Widget _buildNavigationDrawer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
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
                                  const Text(
                                    '2800ml',
                                    style: TextStyle(
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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
} 