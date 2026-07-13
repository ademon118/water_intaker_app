import 'package:flutter/material.dart';
import '../../../app_tokens.dart';
import '../../../core/app_assets.dart';
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

class _ReminderPopupState extends State<ReminderPopup> {
  int _selectedReminderMode = 1;
  int _selectedSnoozeDuration = 1;

  final List<Map<String, dynamic>> _reminderModes = [
    {'name': 'Off', 'asset': AppAssets.reminderOff},
    {'name': 'Auto', 'asset': AppAssets.reminderAuto},
    {'name': 'Silent', 'asset': AppAssets.reminderSilent},
  ];

  void _closePopup() => widget.onClose();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.onSurface.withValues(alpha: 0.25),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closePopup,
              child: const SizedBox.expand(),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Reminder',
                  style: AppTextStyles.inter22Bold
                      .copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_reminderModes.length, (index) {
                    final mode = _reminderModes[index];
                    return _buildReminderModeButton(
                      mode['name'] as String,
                      mode['asset'] as String,
                      index,
                    );
                  }),
                ),
                const SizedBox(height: 28),
                Text(
                  'Snooze for',
                  style: AppTextStyles.inter18SemiBold
                      .copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildSnoozeButton('15mins', 0)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSnoozeButton('30mins', 1)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSnoozeButton('45mins', 2)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSnoozeButton('60mins', 3)),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      final mode =
                          _reminderModes[_selectedReminderMode]['name'] as String;
                      if (mode != 'Off') {
                        await ReminderService.requestPermissions();
                      }
                      await widget.onSaveReminder?.call(
                        mode,
                        _selectedSnoozeDuration,
                      );
                      _closePopup();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: AppTextStyles.inter16SemiBold
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Advanced Settings',
                    style: AppTextStyles.inter14Medium
                        .copyWith(color: colors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderModeButton(String name, String asset, int index) {
    final isSelected = _selectedReminderMode == index;
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedReminderMode = index),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: AppSvg(
                asset,
                width: 24,
                height: 24,
                color: isSelected ? Colors.white : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTextStyles.inter12Medium.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeButton(String duration, int index) {
    final isSelected = _selectedSnoozeDuration == index;
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedSnoozeDuration = index),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: Text(
          duration,
          style: AppTextStyles.inter14Medium.copyWith(
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}
