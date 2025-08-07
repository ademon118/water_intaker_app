import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CongratulationsPopup extends ConsumerStatefulWidget {
  final String badgeName;
  final String badgeDescription;
  final VoidCallback onSave;
  final VoidCallback onViewBadge;

  const CongratulationsPopup({
    super.key,
    required this.badgeName,
    required this.badgeDescription,
    required this.onSave,
    required this.onViewBadge,
  });

  @override
  ConsumerState<CongratulationsPopup> createState() => _CongratulationsPopupState();
}

class _CongratulationsPopupState extends ConsumerState<CongratulationsPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Star Badge with Animation
                    _buildStarBadge(),
                    const SizedBox(height: 20),
                    
                    // Congratulations Text
                    Container(
                      child: const SelectableText(
                        'Congrats',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          decoration: TextDecoration.none,
                        ),
                        enableInteractiveSelection: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Badge Description
                    Container(
                      child: SelectableText(
                        'You earned ${widget.badgeName} badge',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                        enableInteractiveSelection: false,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onSave();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4D8),
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
                    const SizedBox(height: 15),
                    
                    // View Badge Link
                    GestureDetector(
                      onTap: () {
                        widget.onViewBadge();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'View the badge',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00B4D8),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStarBadge() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle with gradient
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00B4D8),
                Color(0xFF0096CC),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B4D8).withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        
        // Main star
        const Icon(
          Icons.star,
          color: Colors.white,
          size: 40,
        ),
        
        // Small decorative dots around the star
        ...List.generate(5, (index) {
          final angle = (index * 72) * (3.14159 / 180); // 72 degrees apart
          final radius = 35.0;
          final x = radius * cos(angle);
          final y = radius * sin(angle);
          
          return Positioned(
            left: 40 + x - 3, // Center at 40, adjust for dot size
            top: 40 + y - 3,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF00B4D8),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ],
    );
  }
}
