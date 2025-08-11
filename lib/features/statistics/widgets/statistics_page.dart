import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/water_intake_service.dart';
import '../../../services/water_intake_provider.dart';
import '../../../models/water_intake.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int _selectedPeriodIndex = 0;
  final List<String> _periods = ['Week', 'Month', 'Year'];
  List<WaterIntake> _intakes = [];
  Map<String, double> _drinkTypeStats = {};
  double _totalIntake = 0;
  double _averageIntake = 0;
  int _totalDrinks = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final selectedDate = ref.read(selectedDateNotifierProvider);
      final intakes = await WaterIntakeService.getIntakesForDate(selectedDate);
      
      // Calculate statistics
      _calculateStatistics(intakes);
      
      setState(() {
        _intakes = intakes;
      });
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  void _calculateStatistics(List<WaterIntake> intakes) {
    _totalIntake = intakes.fold(0, (sum, intake) => sum + intake.amount);
    _totalDrinks = intakes.length;
    _averageIntake = _totalDrinks > 0 ? _totalIntake / _totalDrinks : 0;
    
    // Calculate drink type breakdown
    _drinkTypeStats.clear();
    for (var intake in intakes) {
      _drinkTypeStats[intake.drinkType] = 
          (_drinkTypeStats[intake.drinkType] ?? 0) + intake.amount;
    }
    
    // Calculate streaks (simplified)
    _currentStreak = _calculateCurrentStreak();
    _longestStreak = _calculateLongestStreak();
  }

  int _calculateCurrentStreak() {
    // Simplified streak calculation
    return _totalDrinks > 0 ? _totalDrinks : 0;
  }

  int _calculateLongestStreak() {
    // Simplified longest streak calculation
    return _currentStreak > 10 ? 10 : _currentStreak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPeriodTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 30),
                    _buildDrinkTypeChart(),
                    const SizedBox(height: 30),
                    _buildTrendChart(),
                    const SizedBox(height: 30),
                    _buildDetailedStats(),
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
          Expanded(
            child: Text(
              'Statistics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _periods.asMap().entries.map((entry) {
          int index = entry.key;
          String period = entry.value;
          bool isSelected = index == _selectedPeriodIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriodIndex = index;
                });
                _loadData(); // Reload data for selected period
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'Total Intake',
                value: '${_totalIntake.toInt()}ml',
                icon: Icons.water_drop,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildOverviewCard(
                title: 'Total Drinks',
                value: '$_totalDrinks',
                icon: Icons.local_bar,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'Average',
                value: '${_averageIntake.toInt()}ml',
                icon: Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildOverviewCard(
                title: 'Current Streak',
                value: '$_currentStreak days',
                icon: Icons.local_fire_department,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkTypeChart() {
    if (_drinkTypeStats.isEmpty) {
      return _buildEmptyState('No drink data available');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drink Type Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          ..._drinkTypeStats.entries.map((entry) {
            final percentage = _totalIntake > 0 ? (entry.value / _totalIntake) * 100 : 0;
            return _buildDrinkTypeBar(entry.key, entry.value, percentage as double);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDrinkTypeBar(String drinkType, double amount, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                drinkType,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${amount.toInt()}ml (${percentage.toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intake Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildTrendChartContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChartContent() {
    // Generate sample trend data based on selected period
    List<double> data = [];
    List<String> labels = [];
    
    switch (_selectedPeriodIndex) {
      case 0: // Week
        data = [80, 95, 70, 120, 85, 90, 75];
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        break;
      case 1: // Month
        data = List.generate(30, (index) => 50 + (index % 7) * 10.0);
        labels = List.generate(30, (index) => '${index + 1}');
        break;
      case 2: // Year
        data = List.generate(12, (index) => 2000 + (index % 3) * 500.0);
        labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.asMap().entries.map((entry) {
        int index = entry.key;
        double value = entry.value;
        double maxValue = data.reduce((a, b) => a > b ? a : b);
        
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    heightFactor: value / maxValue,
                    child: Container(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[index],
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow('Longest Streak', '$_longestStreak days', Icons.emoji_events),
          const SizedBox(height: 10),
          _buildStatRow('Best Day', '${_getBestDay()}', Icons.star),
          const SizedBox(height: 10),
          _buildStatRow('Most Common Drink', '${_getMostCommonDrink()}', Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getBestDay() {
    if (_intakes.isEmpty) return 'N/A';
    final bestIntake = _intakes.reduce((a, b) => a.amount > b.amount ? a : b);
    return '${bestIntake.amount.toInt()}ml';
  }

  String _getMostCommonDrink() {
    if (_drinkTypeStats.isEmpty) return 'N/A';
    final mostCommon = _drinkTypeStats.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return mostCommon.key;
  }
}
