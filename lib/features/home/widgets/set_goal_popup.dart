import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/app_settings_provider.dart';

class SetGoalPopup extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final double currentGoal;
  final Function(double newGoal)? onSaveGoal;

  const SetGoalPopup({
    super.key, 
    required this.onClose, 
    required this.currentGoal,
    this.onSaveGoal,
  });

  @override
  ConsumerState<SetGoalPopup> createState() => _SetGoalPopupState();
}

class _SetGoalPopupState extends ConsumerState<SetGoalPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late TextEditingController _goalController;
  bool _isGoalValid = false;

  @override
  void initState() {
    super.initState();
    // Convert current goal to display unit for the text field
    final displayGoal = ref.read(appSettingsProvider.notifier).convertToDisplayUnit(widget.currentGoal);
    _goalController = TextEditingController(text: displayGoal.toInt().toString());
    _checkGoalValidity();
    
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
    _goalController.dispose();
    super.dispose();
  }

  void _checkGoalValidity() {
    final goalText = _goalController.text;
    if (goalText.isNotEmpty) {
      final goal = double.tryParse(goalText);
      setState(() {
        _isGoalValid = goal != null && goal > 0;
      });
    } else {
      setState(() {
        _isGoalValid = false;
      });
    }
  }

  void _closePopup() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  void _saveGoal() {
    if (_isGoalValid) {
      final displayGoal = double.parse(_goalController.text);
      // Convert from display unit to ml for storage
      final goalInMl = ref.read(appSettingsProvider.notifier).convertFromDisplayUnit(displayGoal);
      
      if (widget.onSaveGoal != null) {
        widget.onSaveGoal!(goalInMl);
      }
      _closePopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitLabel = ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6 * _fadeAnimation.value),
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
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
                          Icon(
                            Icons.track_changes,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Set Daily Goal',
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
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Goal input field
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isGoalValid ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: TextField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _checkGoalValidity(),
                          decoration: InputDecoration(
                            hintText: 'Enter your daily goal',
                            suffixText: unitLabel,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Info text
                      Text(
                        'Set a realistic daily water intake goal to stay hydrated and track your progress.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isGoalValid ? _saveGoal : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save Goal',
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