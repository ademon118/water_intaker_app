import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Central paths for icon assets under lib/assets/icons/
class AppAssets {
  AppAssets._();

  // Home
  static const String waterDrop = 'lib/assets/icons/home_water.png';
  static const String drop = 'lib/assets/icons/home_drop.png';
  static const String reminder = 'lib/assets/icons/home_reminder.png';
  static const String target = 'lib/assets/icons/home_target.png';
  static const String trophy = 'lib/assets/icons/home_trophy.png';
  static const String frequency = 'lib/assets/icons/home_frequency.png';

  // Water add popup drinks
  static const String drinkWater = 'lib/assets/icons/drink_water.png';
  static const String drinkMilk = 'lib/assets/icons/drink_milk.png';
  static const String drinkCoffee = 'lib/assets/icons/drink_coffee.png';
  static const String drinkTea = 'lib/assets/icons/drink_tea.png';
  static const String drinkJuice = 'lib/assets/icons/drink_juice.png';
  static const String drinkSmoothie = 'lib/assets/icons/drink_smoothie.png';

  // Reminder modes
  static const String reminderOff = 'lib/assets/icons/reminder_off.png';
  static const String reminderAuto = 'lib/assets/icons/reminder_auto.png';
  static const String reminderSilent = 'lib/assets/icons/reminder_silent.png';

  // Bottom navigation
  static const String navHome = 'lib/assets/icons/nav_home.png';
  static const String navStatistics = 'lib/assets/icons/nav_statistics.png';
  static const String navRewards = 'lib/assets/icons/nav_rewards.png';
  static const String navSettings = 'lib/assets/icons/nav_settings.png';

  static const String toastWater = 'lib/assets/icons/toast_water.png';
  static const String toastReminder = 'lib/assets/icons/toast_reminder.png';

  // Side drawer (dashboard) — PNG extracted from SVG wrappers for web compatibility
  static const String drawerHome = 'lib/assets/icons/drawer_home.png';
  static const String drawerDashboard = 'lib/assets/icons/drawer_dashboard.png';
  static const String drawerReminder = 'lib/assets/icons/drawer_reminder.png';
  static const String drawerAchievements = 'lib/assets/icons/drawer_achievements.png';
  static const String drawerHealthTips = 'lib/assets/icons/drawer_health_tips.png';
  static const String drawerProfile = 'lib/assets/icons/drawer_profile.png';
  static const String drawerSettings = 'lib/assets/icons/drawer_settings.png';

  static String drinkAssetFor(String drinkTypeOrIcon) {
    switch (drinkTypeOrIcon.toLowerCase()) {
      case 'water':
      case 'water_drop':
        return drinkWater;
      case 'milk':
      case 'mug_saucer':
        return drinkMilk;
      case 'coffee':
        return drinkCoffee;
      case 'tea':
      case 'mug_hot':
        return drinkTea;
      case 'juice':
      case 'wine_glass':
        return drinkJuice;
      case 'smoothie':
      case 'blender':
        return drinkSmoothie;
      default:
        return drinkWater;
    }
  }
}

/// Renders a PNG asset icon. Optional [color] tints monochrome icons.
class AppSvg extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AppSvg(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (context) => SizedBox(
          width: width,
          height: height,
        ),
      );
    }

    final image = Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: Icon(
            Icons.broken_image_outlined,
            size: (width ?? height ?? 24) * 0.8,
            color: Colors.grey,
          ),
        );
      },
    );

    if (color == null) return image;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
      child: image,
    );
  }
}
