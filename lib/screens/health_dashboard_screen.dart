import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  int _selectedDay = 32; // current day in cycle (simulating late period)
  int _cycleLength = 28;
  int _periodLength = 5;
  int _lastPeriodDay = 1;
  bool _popupShown = false;

  // Cycle phases
  final List<Map<String, dynamic>> _phases = [
    {'name': 'Menstruation', 'start': 1, 'end': 5, 'color': const Color(0xFFE57373), 'emoji': '🔴'},
    {'name': 'Follicular', 'start': 6, 'end': 13, 'color': const Color(0xFF81C784), 'emoji': '🌱'},
    {'name': 'Ovulation', 'start': 14, 'end': 16, 'color': const Color(0xFFC8A96E), 'emoji': '⭐'},
    {'name': 'Luteal', 'start': 17, 'end': 28, 'color': const Color(0xFF8FA888), 'emoji': '🌙'},
  ];

  // Hormone level simulation data
  final List<FlSpot> _estrogenData = [];
  final List<FlSpot> _progesteroneData = [];
  final List<FlSpot> _lhData = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _generateHormoneData();

    // Show smart popup after short delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && !_popupShown) {
        _showSmartInsightPopup();
        _popupShown = true;
      }
    });
  }

  void _generateHormoneData() {
    for (int i = 1; i <= 32; i++) {
      // Estrogen curve — peaks around ovulation
      double estrogen = 20 + 60 * exp(-0.05 * pow(i - 13, 2)) +
          30 * exp(-0.1 * pow(i - 22, 2));
      _estrogenData.add(FlSpot(i.toDouble(), estrogen.clamp(0, 100)));

      // Progesterone — rises after ovulation
      double progesterone = i < 14 ? 5 : 5 + 70 * exp(-0.08 * pow(i - 22, 2));
      _progesteroneData.add(FlSpot(i.toDouble(), progesterone.clamp(0, 100)));

      // LH surge — sharp peak at ovulation day 14
      double lh = 10 + 80 * exp(-0.5 * pow(i - 14, 2));
      _lhData.add(FlSpot(i.toDouble(), lh.clamp(0, 100)));
    }
  }

  void _showSmartInsightPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardCream,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔴', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Period Alert',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your period is 4 days late this month.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This could be due to stress, changes in diet, or hormonal fluctuations. If this continues, consider consulting a healthcare provider.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGreen,
                        side: const BorderSide(color: AppColors.sageGreen),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Dismiss',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAllInsights();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: AppColors.cardCream,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View Insights',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllInsights() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Health Insights',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      'Based on your cycle data this month',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),
                    _insightCard('🔴', 'Period Alert',
                        'Your period is 4 days late this month. Average delay detected across last 3 cycles.',
                        const Color(0xFFE57373)),
                    const SizedBox(height: 12),
                    _insightCard('⭐', 'Ovulation Window',
                        'Your peak fertility window was around Day 14. Next estimated ovulation: Day 42.',
                        AppColors.gold),
                    const SizedBox(height: 12),
                    _insightCard('😰', 'Stress Correlation',
                        'High stress levels detected during luteal phase (Day 17-28). This may explain the delay.',
                        AppColors.alertOrange),
                    const SizedBox(height: 12),
                    _insightCard('💧', 'Hydration Reminder',
                        'Staying hydrated during your cycle can reduce cramps by up to 40%. Drink 2-3L daily.',
                        AppColors.midGreen),
                    const SizedBox(height: 12),
                    _insightCard('🩺', 'Recommendation',
                        'If your period does not arrive within 7 more days, consider a pregnancy test or consulting a doctor.',
                        AppColors.darkGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard(
      String emoji, String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color == AppColors.cardCream
                          ? AppColors.textDark
                          : color,
                    )),
                const SizedBox(height: 4),
                Text(message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentPhase() {
    for (var phase in _phases) {
      if (_selectedDay >= phase['start'] && _selectedDay <= phase['end']) {
        return phase['name'];
      }
    }
    return 'Late / Irregular';
  }

  Color _getCurrentPhaseColor() {
    for (var phase in _phases) {
      if (_selectedDay >= phase['start'] && _selectedDay <= phase['end']) {
        return phase['color'];
      }
    }
    return AppColors.alertRed;
  }

  String _getCurrentPhaseEmoji() {
    for (var phase in _phases) {
      if (_selectedDay >= phase['start'] && _selectedDay <= phase['end']) {
        return phase['emoji'];
      }
    }
    return '⚠️';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.cardCream, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Health Dashboard',
          style: TextStyle(
            color: AppColors.cardCream,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.lightSage),
            onPressed: _showAllInsights,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cycle Status Card ──
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkGreen,
                        AppColors.midGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getCurrentPhaseEmoji(),
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CURRENT PHASE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.lightSage,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _getCurrentPhase(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.cardCream,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.alertRed.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '4 Days Late',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Cycle day counter row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _cycleStatChip('Day', '$_selectedDay', 'of cycle'),
                          _cycleStatChip('Next Period', 'Overdue', ''),
                          _cycleStatChip('Cycle Length', '$_cycleLength days', 'avg'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Late Period Alert Banner ──
              GestureDetector(
                onTap: _showSmartInsightPopup,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.alertRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.alertRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                            child:
                                Text('⚠️', style: TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your period is 4 days late',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.alertRed,
                              ),
                            ),
                            Text(
                              'Tap to see possible reasons & recommendations',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Cycle Day Tracker ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cycle Day Tracker',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap a day to see your phase details',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 56,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 35,
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final isSelected = day == _selectedDay;
                          Color dayColor = AppColors.lightSage.withOpacity(0.3);

                          for (var phase in _phases) {
                            if (day >= phase['start'] &&
                                day <= phase['end']) {
                              dayColor =
                                  (phase['color'] as Color).withOpacity(0.3);
                            }
                          }
                          if (day > 28) {
                            dayColor = AppColors.alertRed.withOpacity(0.2);
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedDay = day);
                              _showDayPopup(day);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.darkGreen
                                    : dayColor,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.gold, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.cardCream
                                        : AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phase legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _phases
                          .map((p) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: p['color'],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    p['name'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Hormone Graph ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hormone Levels',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Simulated estrogen, progesterone & LH across your cycle',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    // Legend
                    Row(
                      children: [
                        _legendDot(const Color(0xFFE57373), 'Estrogen'),
                        const SizedBox(width: 16),
                        _legendDot(AppColors.gold, 'Progesterone'),
                        const SizedBox(width: 16),
                        _legendDot(AppColors.midGreen, 'LH Surge'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minX: 1,
                          maxX: 35,
                          minY: 0,
                          maxY: 110,
                          clipData: const FlClipData.all(),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 25,
                            verticalInterval: 7,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppColors.sageGreen.withOpacity(0.15),
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: AppColors.sageGreen.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 7,
                                getTitlesWidget: (val, meta) => Text(
                                  'Day ${val.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Vertical line for current day
                          extraLinesData: ExtraLinesData(
                            verticalLines: [
                              VerticalLine(
                                x: _selectedDay.toDouble(),
                                color: AppColors.darkGreen.withOpacity(0.6),
                                strokeWidth: 2,
                                dashArray: [4, 4],
                                label: VerticalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.darkGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  labelResolver: (line) =>
                                      'Day ${_selectedDay}',
                                ),
                              ),
                            ],
                          ),
                          lineBarsData: [
                            // Estrogen
                            LineChartBarData(
                              spots: _estrogenData,
                              isCurved: true,
                              curveSmoothness: 0.4,
                              color: const Color(0xFFE57373),
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color:
                                    const Color(0xFFE57373).withOpacity(0.08),
                              ),
                            ),
                            // Progesterone
                            LineChartBarData(
                              spots: _progesteroneData,
                              isCurved: true,
                              curveSmoothness: 0.4,
                              color: AppColors.gold,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.gold.withOpacity(0.08),
                              ),
                            ),
                            // LH
                            LineChartBarData(
                              spots: _lhData,
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: AppColors.midGreen,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Ovulation Prediction Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⭐',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        const Text(
                          'Ovulation Prediction',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'AI Predicted',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ovulationStat('Last Ovulation', 'Day 14', '18 days ago'),
                        const SizedBox(width: 12),
                        _ovulationStat('Next Ovulation', 'Day 42', 'Est. ~10 days'),
                        const SizedBox(width: 12),
                        _ovulationStat('Fertility', 'LOW', 'Currently'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Text('💡', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your ovulation window is estimated based on your last cycle. Accuracy improves with more cycle data.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Symptom Tracker ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Common Symptoms This Phase',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _symptomChip('😴 Fatigue', true),
                        _symptomChip('🤕 Cramps', false),
                        _symptomChip('😰 Mood Swings', true),
                        _symptomChip('🤢 Nausea', false),
                        _symptomChip('💊 Bloating', true),
                        _symptomChip('😟 Anxiety', false),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── View All Insights Button ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _showAllInsights,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: AppColors.cardCream,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🤖',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'View All AI Insights',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayPopup(int day) {
    String phase = 'Late / Irregular';
    String emoji = '⚠️';
    String description = 'Your cycle appears to be running late. Monitor symptoms.';
    Color color = AppColors.alertRed;

    for (var p in _phases) {
      if (day >= p['start'] && day <= p['end']) {
        phase = p['name'];
        emoji = p['emoji'];
        color = p['color'];
        switch (phase) {
          case 'Menstruation':
            description =
                'Your period is active. Stay hydrated and rest well. Cramps may be present.';
            break;
          case 'Follicular':
            description =
                'Estrogen is rising. Energy levels increase. Great time for exercise!';
            break;
          case 'Ovulation':
            description =
                'Peak fertility window! LH surge detected. Highest chance of conception.';
            break;
          case 'Luteal':
            description =
                'Progesterone rises. PMS symptoms may appear. Prioritize rest and nutrition.';
            break;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardCream,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                'Day $day — $phase',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got it',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cycleStatChip(String label, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardCream.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.lightSage,
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cardCream,
                )),
            if (sub.isNotEmpty)
              Text(sub,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.lightSage)),
          ],
        ),
      ),
    );
  }

  Widget _ovulationStat(String label, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted,
                    letterSpacing: 0.3)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                )),
            Text(sub,
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _symptomChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.darkGreen.withOpacity(0.1)
            : AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.darkGreen.withOpacity(0.3)
              : AppColors.sageGreen.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppColors.darkGreen : AppColors.textMuted,
        ),
      ),
    );
  }
}
