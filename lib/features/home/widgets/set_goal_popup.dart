import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_tokens.dart';
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

class _SetGoalPopupState extends ConsumerState<SetGoalPopup> {
  late TextEditingController _goalController;
  bool _isGoalValid = false;

  @override
  void initState() {
    super.initState();
    final displayGoal = ref
        .read(appSettingsProvider.notifier)
        .convertToDisplayUnit(widget.currentGoal);
    _goalController =
        TextEditingController(text: displayGoal.toInt().toString());
    _checkGoalValidity();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _closePopup() => widget.onClose();

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

  void _saveGoal() {
    if (!_isGoalValid) return;
    final displayGoal = double.parse(_goalController.text);
    final goalInMl = ref
        .read(appSettingsProvider.notifier)
        .convertFromDisplayUnit(displayGoal);
    widget.onSaveGoal?.call(goalInMl);
    _closePopup();
  }

  @override
  Widget build(BuildContext context) {
    final unitLabel =
        ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
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
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                Row(
                  children: [
                    Icon(
                      Icons.track_changes,
                      color: colors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Set Daily Goal',
                        style: AppTextStyles.inter22Bold
                            .copyWith(color: colors.onSurface),
                      ),
                    ),
                    IconButton(
                      onPressed: _closePopup,
                      icon: const Icon(Icons.close),
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isGoalValid
                          ? colors.tertiary
                          : colors.surfaceContainerHighest,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _checkGoalValidity(),
                    decoration: InputDecoration(
                      hintText: 'Enter your daily goal',
                      suffixText: unitLabel,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    style: AppTextStyles.inter18SemiBold
                        .copyWith(color: colors.onSurface),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Set a realistic daily water intake goal to stay hydrated and track your progress.',
                  style: AppTextStyles.inter14Regular.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isGoalValid ? _saveGoal : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Goal',
                      style: AppTextStyles.inter16SemiBold
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 12),
        ],
      ),
    );
  }
}
