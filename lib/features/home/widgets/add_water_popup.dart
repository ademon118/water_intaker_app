import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/water_intake_provider.dart';
import '../../../services/app_settings_provider.dart';

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
  double _selectedAmount = 250; // Default amount in ml

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

  void _addWater() {
    if (_selectedDrinkIndex >= 0) {
      final drinkTypes = ref.read(drinkTypesProvider);
      final selectedDrink = drinkTypes[_selectedDrinkIndex];
      final amountInMl = _selectedAmount.toInt();
      
      if (widget.onAddWater != null) {
        widget.onAddWater!(amountInMl, selectedDrink['name']);
      }
      _closePopup();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'coffee':
        return FontAwesomeIcons.coffee;
      case 'mug_hot':
        return FontAwesomeIcons.mugHot;
      case 'mug_saucer':
        return FontAwesomeIcons.mugSaucer;
      case 'blender':
        return FontAwesomeIcons.blender;
      case 'wine_glass':
        return FontAwesomeIcons.wineGlass;
      default:
        return Icons.local_bar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final drinkTypes = ref.watch(drinkTypesProvider);
    final unitLabel = ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
    final displayAmount = ref.read(appSettingsProvider.notifier).convertToDisplayUnit(_selectedAmount);
    
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
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(
                            Icons.add_circle,
                            color: Color(0xFF00B4D8),
                            size: 28,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Add Water Intake',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _closePopup,
                            icon: const Icon(Icons.close),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Drink type selection
                      Text(
                        'Select Drink Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Drink type grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: drinkTypes.length,
                        itemBuilder: (context, index) {
                          final drink = drinkTypes[index];
                          final isSelected = index == _selectedDrinkIndex;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDrinkIndex = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF00B4D8).withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFF00B4D8)
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconData(drink['icon']),
                                    size: 32,
                                    color: isSelected 
                                        ? const Color(0xFF00B4D8)
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    drink['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected 
                                          ? const Color(0xFF00B4D8)
                                          : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Amount selection
                      Text(
                        'Select Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Amount slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF00B4D8),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayColor: const Color(0xFF00B4D8).withOpacity(0.2),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        ),
                        child: Slider(
                          value: _selectedAmount,
                          min: 50,
                          max: 500,
                          divisions: 45,
                          onChanged: (value) {
                            setState(() {
                              _selectedAmount = value;
                            });
                          },
                        ),
                      ),
                      
                      // Amount display
                      Text(
                        '${displayAmount.toStringAsFixed(1)}$unitLabel',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00B4D8),
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Add button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedDrinkIndex >= 0 ? _addWater : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B4D8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Add ${displayAmount.toStringAsFixed(1)}$unitLabel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom spacing
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        );
      },
    );
  }
} 