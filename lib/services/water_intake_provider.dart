import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/water_intake.dart';
import 'water_intake_service.dart';

part 'water_intake_provider.g.dart';

@riverpod
class WaterIntakeNotifier extends _$WaterIntakeNotifier {
  @override
  List<WaterIntake> build() {
    return WaterIntakeService.getIntakesForDate(DateTime.now());
  }

  Future<void> addWaterIntake(WaterIntake intake) async {
    await WaterIntakeService.addWaterIntake(intake);
    state = WaterIntakeService.getIntakesForDate(intake.date);
  }

  void loadIntakesForDate(DateTime date) {
    state = WaterIntakeService.getIntakesForDate(date);
  }

  int getTotalIntakeForDate(DateTime date) {
    return WaterIntakeService.getTotalIntakeForDate(date);
  }

  Map<String, int> getDrinkTypeBreakdownForDate(DateTime date) {
    return WaterIntakeService.getDrinkTypeBreakdownForDate(date);
  }
}

@riverpod
List<Map<String, dynamic>> drinkTypes(DrinkTypesRef ref) {
  return WaterIntakeService.getAllDrinkTypes();
}

@riverpod
class SelectedDateNotifier extends _$SelectedDateNotifier {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setDate(DateTime date) {
    state = date;
  }
}
