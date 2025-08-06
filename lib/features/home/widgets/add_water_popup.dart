import 'package:flutter/material.dart';

class AddWaterPopup extends StatefulWidget {
  final VoidCallback onClose;

  const AddWaterPopup({super.key, required this.onClose});

  @override
  State<AddWaterPopup> createState() => _AddWaterPopupState();
}

class _AddWaterPopupState extends State<AddWaterPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _selectedDrinkIndex = -1;
  double _selectedAmount = 250; // Default amount

  final List<Map<String, dynamic>> _drinks = [
    {
      'name': 'Water',
      'icon': Icons.water_drop,
      'amount': 250,
    },
    {
      'name': 'Coffee',
      'icon': Icons.local_cafe,
      'amount': 300,
    },
    {
      'name': 'Tea',
      'icon': Icons.local_drink,
      'amount': 250,
    },
    {
      'name': 'Milk',
      'icon': Icons.local_drink,
      'amount': 300,
    },
    {
      'name': 'Smoothie',
      'icon': Icons.local_bar,
      'amount': 350,
    },
    {
      'name': 'Juice',
      'icon': Icons.local_bar,
      'amount': 300,
    },
  ];

  final List<double> _amountOptions = [100, 150, 200, 250, 300, 350, 400, 500];

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
                      
                      // Header with title and add drink button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Water',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: _closePopup,
                              child: const Text(
                                'Add Drink',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00B4D8), // 00B4D8 blue color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Drink selection buttons (horizontal layout)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDrinkButton('Milk', Icons.local_drink, 0),
                            _buildDrinkButton('Water', Icons.water_drop, 1),
                            _buildDrinkButton('Coffee', Icons.local_cafe, 2),
                            _buildDrinkButton('Juice', Icons.local_bar, 3),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Amount adjustment section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Amount display
                            Text(
                              '${_selectedAmount.toInt()}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400], // Light grey for amount display
                              ),
                            ),
                            
                            // Slider with plus/minus buttons
                            Column(
                              children: [
                                // ml text at the top
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Text(
                                      'ml',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF00B4D8), // 00B4D8 blue color
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Slider row with aligned buttons
                                Row(
                                  children: [
                                    // Minus button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_selectedAmount > 50) {
                                            _selectedAmount -= 50;
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.black87,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 20),
                                    
                                    // Slider
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: const Color(0xFF00B4D8), // 00B4D8 slider color
                                          inactiveTrackColor: Colors.grey[300],
                                          thumbColor: Colors.grey[400],
                                          trackHeight: 4,
                                        ),
                                        child: Slider(
                                          value: _selectedAmount,
                                          min: 50,
                                          max: 1000,
                                          divisions: 19,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedAmount = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 20),
                                    
                                    // Plus button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_selectedAmount < 1000) {
                                            _selectedAmount += 50;
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.black87,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                            onPressed: _selectedDrinkIndex >= 0 ? () {
                              // Add drink logic here
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

  Widget _buildDrinkButton(String name, IconData icon, int index) {
    final isSelected = _selectedDrinkIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDrinkIndex = index;
          _selectedAmount = _drinks[index]['amount'];
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFF1F5F9) // F1F5F9 background for selected
              : const Color(0xFFD9D9D9), // D9D9D9 unselected drink color
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
            const SizedBox(height: 4),
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
} 