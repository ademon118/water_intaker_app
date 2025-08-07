import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/water_intake_provider.dart';

class AddWaterPopup extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(int amount, String drinkType)? onAddWater;

  const AddWaterPopup({
    super.key, 
    required this.onClose,
    this.onAddWater,
  });

  @override
  ConsumerState<AddWaterPopup> createState() => _AddWaterPopupState();
}

class _AddWaterPopupState extends ConsumerState<AddWaterPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _selectedDrinkIndex = -1;
  double _selectedAmount = 250; // Default amount

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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_drink':
        return Icons.local_drink;
      case 'local_bar':
        return Icons.local_bar;
      default:
        return Icons.local_bar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final drinkTypes = ref.watch(drinkTypesProvider);
    
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
                              'Add Drink',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: _closePopup,
                              child: const Text(
                                'Cancel',
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
                          children: drinkTypes.take(4).map((drink) {
                            final index = drinkTypes.indexOf(drink);
                            return _buildDrinkButton(
                              drink['name'], 
                              _getIconData(drink['icon']), 
                              index,
                              drink['defaultAmount'],
                            );
                          }).toList(),
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
                              if (widget.onAddWater != null && _selectedDrinkIndex < drinkTypes.length) {
                                final selectedDrink = drinkTypes[_selectedDrinkIndex];
                                widget.onAddWater!(_selectedAmount.toInt(), selectedDrink['name']);
                              }
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

  Widget _buildDrinkButton(String name, IconData icon, int index, int defaultAmount) {
    final isSelected = _selectedDrinkIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDrinkIndex = index;
          _selectedAmount = defaultAmount.toDouble();
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