import 'package:hive/hive.dart';

part 'water_intake.g.dart';

@HiveType(typeId: 0)
class WaterIntake extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final String drinkType;

  @HiveField(3)
  final DateTime timestamp;

  WaterIntake({
    required this.date,
    required this.amount,
    required this.drinkType,
    required this.timestamp,
  });
} 