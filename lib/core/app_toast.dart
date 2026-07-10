import 'dart:async';

import 'package:flutter/material.dart';

import '../app_tokens.dart';
import 'app_assets.dart';

enum AppToastType { drinkAdded, reminderSet, error }

class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    required AppToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);
    final topInset = MediaQuery.of(context).padding.top;

    _entry = OverlayEntry(
      builder: (context) => _AppToastBanner(
        message: message,
        type: type,
        topInset: topInset,
        onClose: dismiss,
      ),
    );

    overlay.insert(_entry!);

    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _AppToastBanner extends StatefulWidget {
  final String message;
  final AppToastType type;
  final double topInset;
  final VoidCallback onClose;

  const _AppToastBanner({
    required this.message,
    required this.type,
    required this.topInset,
    required this.onClose,
  });

  @override
  State<_AppToastBanner> createState() => _AppToastBannerState();
}

class _AppToastBannerState extends State<_AppToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _iconAsset {
    switch (widget.type) {
      case AppToastType.drinkAdded:
        return AppAssets.toastWater;
      case AppToastType.reminderSet:
        return AppAssets.toastReminder;
      case AppToastType.error:
        return AppAssets.drop;
    }
  }

  Color get _iconBackground {
    switch (widget.type) {
      case AppToastType.drinkAdded:
        return const Color(0xFFE8F4FF);
      case AppToastType.reminderSet:
        return const Color(0xFFFFF3E0);
      case AppToastType.error:
        return const Color(0xFFFFEBEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned(
      top: widget.topInset + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _iconBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        _iconAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          widget.type == AppToastType.reminderSet
                              ? Icons.notifications_active
                              : Icons.water_drop,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.inter14Medium.copyWith(
                        color: colors.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
