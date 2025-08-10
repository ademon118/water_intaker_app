import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_settings_service.dart';
import '../../../models/user_settings.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  UserSettings? _userSettings;
  bool _isDarkMode = false;
  String _selectedUnit = 'ml';
  double _dailyGoal = 2800;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await UserSettingsService.loadSettings();
      setState(() {
        _userSettings = settings;
        _dailyGoal = settings.dailyGoal;
        _selectedUnit = settings.unit;
        _isDarkMode = settings.isDarkMode;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _dailyGoal = 2800.0;
        _selectedUnit = 'ml';
        _isDarkMode = false;
      });
    }
  }

  Future<void> _updateDailyGoal(double newGoal) async {
    try {
      await UserSettingsService.updateDailyGoal(newGoal);
      setState(() {
        _dailyGoal = newGoal;
      });
    } catch (e) {
      print('Error updating daily goal: $e');
    }
  }

  Future<void> _updateUnit(String newUnit) async {
    try {
      await UserSettingsService.updateUnit(newUnit);
      setState(() {
        _selectedUnit = newUnit;
      });
    } catch (e) {
      print('Error updating unit: $e');
    }
  }

  Future<void> _updateAppearance(bool isDarkMode) async {
    try {
      await UserSettingsService.updateAppearance(isDarkMode);
      setState(() {
        _isDarkMode = isDarkMode;
      });
    } catch (e) {
      print('Error updating appearance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
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
                      value: '${_dailyGoal.toInt()} $_selectedUnit',
                      onChanged: _updateDailyGoal,
                      min: 1000,
                      max: 5000,
                      divisions: 40,
                    ),
                    const SizedBox(height: 20),
                    _buildNavigationSetting(
                      title: 'Water intake',
                      onTap: () {},
                    ),
                    const SizedBox(height: 15),
                    _buildNavigationSetting(
                      title: 'Units',
                      value: _selectedUnit == 'ml' ? 'ml' : 'oz',
                      onTap: () => _showUnitSelectionDialog(),
                    ),
                    const SizedBox(height: 15),
                    _buildNavigationSetting(
                      title: 'Appearance',
                      value: _isDarkMode ? 'Dark' : 'Light',
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
              value: _dailyGoal,
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
        color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitOption('Ounces, oz', 'oz'),
            const SizedBox(height: 10),
            _buildUnitOption('Milliliters, ml', 'ml'),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption(String label, String unit) {
    return ListTile(
      title: Text(label),
      trailing: _selectedUnit == unit
          ? const Icon(Icons.check, color: Color(0xFF00B4D8))
          : null,
      onTap: () {
        _updateUnit(unit);
        Navigator.pop(context);
      },
    );
  }

  void _showAppearanceSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Appearance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppearanceOption('Light Mode', false),
            const SizedBox(height: 10),
            _buildAppearanceOption('Dark Mode', true),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceOption(String label, bool isDark) {
    return ListTile(
      title: Text(label),
      trailing: _isDarkMode == isDark
          ? const Icon(Icons.check, color: Color(0xFF00B4D8))
          : null,
      onTap: () {
        _updateAppearance(isDark);
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
