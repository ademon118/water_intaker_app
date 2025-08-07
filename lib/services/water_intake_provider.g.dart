// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_intake_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$drinkTypesHash() => r'566a5b6c721bdb5883f29a9e310c20696e44e206';

/// See also [drinkTypes].
@ProviderFor(drinkTypes)
final drinkTypesProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>.internal(
  drinkTypes,
  name: r'drinkTypesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$drinkTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DrinkTypesRef = AutoDisposeProviderRef<List<Map<String, dynamic>>>;
String _$waterIntakeNotifierHash() =>
    r'a89867341b08afe0dba76633bbe9601dee4891f9';

/// See also [WaterIntakeNotifier].
@ProviderFor(WaterIntakeNotifier)
final waterIntakeNotifierProvider = AutoDisposeNotifierProvider<
    WaterIntakeNotifier, List<WaterIntake>>.internal(
  WaterIntakeNotifier.new,
  name: r'waterIntakeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$waterIntakeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WaterIntakeNotifier = AutoDisposeNotifier<List<WaterIntake>>;
String _$selectedDateNotifierHash() =>
    r'01d1399ef531edb19db035a626ef03677b8c582e';

/// See also [SelectedDateNotifier].
@ProviderFor(SelectedDateNotifier)
final selectedDateNotifierProvider =
    AutoDisposeNotifierProvider<SelectedDateNotifier, DateTime>.internal(
  SelectedDateNotifier.new,
  name: r'selectedDateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedDateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDateNotifier = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
