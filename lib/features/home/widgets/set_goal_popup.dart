import 'package:flutter/material.dart';

class SetGoalPopup extends StatefulWidget {
  final VoidCallback onClose;
  final double currentGoal;

  const SetGoalPopup({super.key, required this.onClose, required this.currentGoal});

  @override
  State<SetGoalPopup> createState() => _SetGoalPopupState();
}

class _SetGoalPopupState extends State<SetGoalPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late TextEditingController _goalController;
  bool _isGoalValid = false;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.currentGoal.toInt().toString());
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
                        'Set A New Goal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Enter the goal section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter the goal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            // Goal input field
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9), // Light grey background
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isGoalValid 
                                      ? const Color(0xFF00B4D8) 
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _goalController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _checkGoalValidity();
                                },
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Enter goal amount',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Save button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isGoalValid ? () {
                              // Save goal logic here
                              final newGoal = double.tryParse(_goalController.text);
                              if (newGoal != null) {
                                // Update the goal in the parent widget
                                _closePopup();
                              }
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
                              'Save',
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
} 