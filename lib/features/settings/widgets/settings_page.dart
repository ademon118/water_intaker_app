import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_settings_service.dart';
import '../../../services/app_settings_provider.dart';
import '../../../models/user_settings.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final userSettings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSectionHeader('GENERAL'),
                    const SizedBox(height: 15),
                    _buildSliderSetting(
                      title: 'Daily water intake goal',
                      value: '${ref.read(appSettingsProvider.notifier).convertToDisplayUnit(userSettings.dailyGoal).toStringAsFixed(1)} ${ref.read(appSettingsProvider.notifier).getUnitAbbreviation()}',
                      onChanged: (newGoal) {
                        // Convert from display unit to ml for storage
                        final goalInMl = ref.read(appSettingsProvider.notifier).convertFromDisplayUnit(newGoal);
                        ref.read(appSettingsProvider.notifier).updateDailyGoal(goalInMl);
                      },
                      min: ref.read(appSettingsProvider.notifier).convertToDisplayUnit(1000.0),
                      max: ref.read(appSettingsProvider.notifier).convertToDisplayUnit(5000.0),
                      divisions: 40,
                      currentValue: ref.read(appSettingsProvider.notifier).convertToDisplayUnit(userSettings.dailyGoal),
                    ),
                    const SizedBox(height: 20),
                    _buildNavigationSetting(
                      title: 'Water intake',
                      onTap: () {},
                    ),
                    const SizedBox(height: 15),
                    _buildNavigationSetting(
                      title: 'Units',
                      value: userSettings.unit == 'ml' ? 'ml' : 'oz',
                      onTap: () => _showUnitSelectionDialog(),
                    ),
                    const SizedBox(height: 15),
                    _buildNavigationSetting(
                      title: 'Appearance',
                      value: userSettings.isDarkMode ? 'Dark' : 'Light',
                      onTap: () => _showAppearanceSelectionDialog(),
                    ),
                    const SizedBox(height: 15),
                    _buildNavigationSetting(
                      title: 'Drinks info',
                      onTap: () => _showDrinksInfoDialog(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String value,
    required Function(double) onChanged,
    required double min,
    required double max,
    required int divisions,
    required double currentValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
              value: currentValue,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSetting({
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (value != null) ...[
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUnitSelectionDialog() {
    final currentUnit = ref.read(appSettingsProvider).unit;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitOption('Ounces, oz', 'oz', currentUnit == 'oz'),
            const SizedBox(height: 10),
            _buildUnitOption('Milliliters, ml', 'ml', currentUnit == 'ml'),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption(String label, String unit, bool isSelected) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF00B4D8))
          : null,
      onTap: () {
        ref.read(appSettingsProvider.notifier).updateUnit(unit);
        Navigator.pop(context);
      },
    );
  }

  void _showAppearanceSelectionDialog() {
    final isDarkMode = ref.read(appSettingsProvider).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Appearance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppearanceOption('Light Mode', false, !isDarkMode),
            const SizedBox(height: 10),
            _buildAppearanceOption('Dark Mode', true, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceOption(String label, bool isDark, bool isSelected) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF00B4D8))
          : null,
      onTap: () {
        ref.read(appSettingsProvider.notifier).updateTheme(isDark);
        Navigator.pop(context);
      },
    );
  }

  void _showDrinksInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drink Categories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrinkCategory('Water', 'Pure water for hydration', Icons.water_drop),
            const SizedBox(height: 10),
            _buildDrinkCategory('Coffee', 'Coffee and espresso drinks', Icons.coffee),
            const SizedBox(height: 10),
            _buildDrinkCategory('Tea', 'Various types of tea', Icons.local_cafe),
            const SizedBox(height: 10),
            _buildDrinkCategory('Milk', 'Dairy and plant-based milk', Icons.local_drink),
            const SizedBox(height: 10),
            _buildDrinkCategory('Smoothie', 'Fruit and vegetable smoothies', Icons.blender),
            const SizedBox(height: 10),
            _buildDrinkCategory('Juice', 'Fresh fruit and vegetable juices', Icons.local_bar),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkCategory(String name, String description, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00B4D8), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
