import 'package:hive_flutter/hive_flutter.dart';
import '../models/water_intake.dart';

class WaterIntakeService {
  static const String _boxName = 'water_intakes';
  static Box<WaterIntake>? _box;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WaterIntakeAdapter());
    _box = await Hive.openBox<WaterIntake>(_boxName);
  }

  static Future<void> addWaterIntake(WaterIntake intake) async {
    await _box?.add(intake);
  }

  static List<WaterIntake> getIntakesForDate(DateTime date) {
    if (_box == null) return [];
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box!.values.where((intake) {
      return intake.date.isAfter(startOfDay) && intake.date.isBefore(endOfDay);
    }).toList();
  }

  static int getTotalIntakeForDate(DateTime date) {
    final intakes = getIntakesForDate(date);
    return intakes.fold(0, (sum, intake) => sum + intake.amount);
  }

  static List<WaterIntake> getIntakesForDateRange(DateTime startDate, DateTime endDate) {
    if (_box == null) return [];
    
    return _box!.values.where((intake) {
      return intake.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             intake.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  static Map<String, int> getDrinkTypeBreakdownForDate(DateTime date) {
    final intakes = getIntakesForDate(date);
    final breakdown = <String, int>{};
    
    for (final intake in intakes) {
      breakdown[intake.drinkType] = (breakdown[intake.drinkType] ?? 0) + intake.amount;
    }
    
    return breakdown;
  }

  static List<Map<String, dynamic>> getAllDrinkTypes() {
    return [
      {
        'name': 'Water',
        'icon': 'water_drop',
        'defaultAmount': 250,
      },
      {
        'name': 'Coffee',
        'icon': 'local_cafe',
        'defaultAmount': 300,
      },
      {
        'name': 'Tea',
        'icon': 'local_drink',
        'defaultAmount': 250,
      },
      {
        'name': 'Milk',
        'icon': 'local_drink',
        'defaultAmount': 300,
      },
      {
        'name': 'Smoothie',
        'icon': 'local_bar',
        'defaultAmount': 350,
      },
      {
        'name': 'Juice',
        'icon': 'local_bar',
        'defaultAmount': 300,
      },
    ];
  }

  static Future<void> deleteIntake(String id) async {
    await _box?.delete(id);
  }

  static Future<void> clearAllData() async {
    await _box?.clear();
  }
} 