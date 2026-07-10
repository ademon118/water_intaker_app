import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_tokens.dart';
import '../../../core/app_assets.dart';
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

class _AddWaterPopupState extends ConsumerState<AddWaterPopup> {
  int _selectedDrinkIndex = 0;
  double _selectedAmount = 250;

  void _closePopup() => widget.onClose();

  void _addWater() {
    if (_selectedDrinkIndex < 0) return;
    final drinkTypes = ref.read(drinkTypesProvider);
    final selectedDrink = drinkTypes[_selectedDrinkIndex];
    widget.onAddWater?.call(_selectedAmount.toInt(), selectedDrink['name']);
    _closePopup();
  }

  void _adjustAmount(double delta) {
    setState(() {
      _selectedAmount = (_selectedAmount + delta).clamp(50, 1000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final drinkTypes = ref.watch(drinkTypesProvider);
    final unitLabel =
        ref.read(appSettingsProvider.notifier).getUnitAbbreviation();
    final displayAmount = ref
        .read(appSettingsProvider.notifier)
        .convertToDisplayUnit(_selectedAmount);
    final selectedName = drinkTypes[_selectedDrinkIndex]['name'] as String;
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
            constraints: const BoxConstraints(maxHeight: 544),
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
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
                Row(
                  children: [
                    Text(
                      selectedName,
                      style: AppTextStyles.inter22Bold
                          .copyWith(color: colors.onSurface),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Add Drink',
                        style: AppTextStyles.inter14Medium
                            .copyWith(color: colors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: drinkTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final drink = drinkTypes[index];
                      final isSelected = index == _selectedDrinkIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDrinkIndex = index;
                            _selectedAmount =
                                (drink['defaultAmount'] as int).toDouble();
                          });
                        },
                        child: Container(
                          width: 88,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primaryContainer.withValues(alpha: 0.55)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(18),
                            border: isSelected
                                ? Border.all(color: colors.primary, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppSvg(
                                AppAssets.drinkAssetFor(
                                  drink['icon'] as String,
                                ),
                                width: 36,
                                height: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                drink['name'] as String,
                                style: AppTextStyles.interSemiBold(
                                  13,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${displayAmount.toInt()}',
                  style: AppTextStyles.interSemiBold(
                    36,
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                Text(
                  unitLabel,
                  style: AppTextStyles.inter14Regular
                      .copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _roundIconButton(
                      icon: Icons.remove,
                      onTap: () => _adjustAmount(-10),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: colors.primary,
                          inactiveTrackColor: colors.primaryContainer,
                          thumbColor: colors.primary,
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 18,
                          ),
                        ),
                        child: Slider(
                          value: _selectedAmount,
                          min: 50,
                          max: 1000,
                          divisions: 95,
                          onChanged: (value) {
                            setState(() => _selectedAmount = value);
                          },
                        ),
                      ),
                    ),
                    _roundIconButton(
                      icon: Icons.add,
                      onTap: () => _adjustAmount(10),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _addWater,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF2E2E2E)),
      ),
    );
  }
}
