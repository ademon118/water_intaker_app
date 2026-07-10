import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/widgets/home_page.dart';
import 'services/water_intake_service.dart';
import 'services/reminder_service.dart';
import 'services/app_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WaterIntakeService.initialize();
  await ReminderService.initialize();
  runApp(const ProviderScope(child: WaterIntakeApp()));
}

class WaterIntakeApp extends ConsumerWidget {
  const WaterIntakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Intaker',
      theme: themeData,
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}
