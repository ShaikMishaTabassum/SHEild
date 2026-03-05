import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> with TickerProviderStateMixin {
  final List<FlSpot> _liveData = [];
  double _currentStress = 28;
  int _tick = 0;
  late Timer _dataTimer;
  final Random _random = Random();

  // Meditation timer
  bool _meditating = false;
  int _meditationSeconds = 0;
  int _meditationGoal = 300; // 5 minutes
  Timer? _meditationTimer;
  late AnimationController _breathController;
  late Animation<double> _breathAnim;

  // Triggers log
  final List<Map<String, dynamic>> _triggers = [
    {'time': '09:15 AM', 'trigger': 'Work meeting', 'level': 72.0, 'emoji': '💼'},
    {'time': '11:30 AM', 'trigger': 'Traffic commute', 'level': 58.0, 'emoji': '🚗'},
    {'time': '01:00 PM', 'trigger': 'Lunch break', 'level': 22.0, 'emoji': '🍽️'},
    {'time': '03:45 PM', 'trigger': 'Deadline pressure', 'level': 81.0, 'emoji': '⏰'},
    {'time': '06:00 PM', 'trigger': 'Evening walk', 'level': 18.0, 'emoji': '🌿'},
  ];

  // Weekly data
  final List<Map<String, dynamic>> _weekly = [
    {'day': 'Mon', 'avg': 42.0},
    {'day': 'Tue', 'avg': 65.0},
    {'day': 'Wed', 'avg': 38.0},
    {'day': 'Thu', 'avg': 71.0},
    {'day': 'Fri', 'avg': 55.0},
    {'day': 'Sat', 'avg': 28.0},
    {'day': 'Sun', 'avg': 32.0},
  ];

  String get _stressLabel => _currentStress < 30 ? 'LOW' : _currentStress < 55 ? 'MODERATE' : 'HIGH';
  Color get _stressColor => _currentStress < 30 ? AppColors.safeGreen : _currentStress < 55 ? AppColors.alertOrange : AppColors.alertRed;
  String get _stressAdvice => _currentStress < 30 ? 'Great! You\'re calm and balanced.' : _currentStress < 55 ? 'Mild stress. Take short breaks.' : 'High stress! Try meditation now.';

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _breathController, curve: Curves.easeInOut));

    for (int i = 0; i < 20; i++) {
      _liveData.add(FlSpot(i.toDouble(), 22 + _random.nextDouble() * 14));
    }
    _tick = 20;

    _dataTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _tick++;
        _currentStress = (_currentStress + (_random.nextDouble() - 0.45) * 3).clamp(10, 90);
        _liveData.add(FlSpot(_tick.toDouble(), _currentStress));
        if (_liveData.length > 20) _liveData.removeAt(0);
      });
    });
  }

  void _startMeditation() {
    setState(() {
      _meditating = true;
      _meditationSeconds = 0;
    });
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _meditationSeconds++;
        if (_meditationSeconds >= _meditationGoal) _stopMeditation();
      });
    });
  }

  void _stopMeditation() {
    _meditationTimer?.cancel();
    setState(() => _meditating = false);
    if (_meditationSeconds >= _meditationGoal) _showMeditationComplete();
  }

  void _showMeditationComplete() {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🧘', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Session Complete!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          const Text('Great job! You completed a 5-minute meditation. Your stress levels should reduce in the next few minutes.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen, foregroundColor: AppColors.cardCream, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Done 🌿', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
        ]),
      ),
    ));
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _breathController.dispose();
    _dataTimer.cancel();
    _meditationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minX = _tick - 19.0;
    final maxX = _tick.toDouble();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Stress Monitor', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          Container(margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.safeGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.safeGreen, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('LIVE', style: TextStyle(fontSize: 11, color: AppColors.safeGreen, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ])),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Current Stress Hero ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3D6B5C), Color(0xFF2C4A3E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('STRESS INDEX', style: TextStyle(fontSize: 10, color: AppColors.lightSage, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_currentStress.toStringAsFixed(0), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.cardCream, height: 1)),
                    const Padding(padding: EdgeInsets.only(bottom: 8, left: 6), child: Text('%', style: TextStyle(fontSize: 18, color: AppColors.lightSage, fontWeight: FontWeight.w500))),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: _stressColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: _stressColor.withOpacity(0.5))),
                    child: Text(_stressLabel, style: TextStyle(fontSize: 12, color: _stressColor, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const Spacer(),
                const Text('🧠', style: TextStyle(fontSize: 52)),
              ]),
              const SizedBox(height: 16),
              // Gauge bar
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Calm', style: TextStyle(fontSize: 10, color: AppColors.lightSage)),
                  Text(_stressAdvice, style: const TextStyle(fontSize: 10, color: AppColors.lightSage)),
                  const Text('High', style: TextStyle(fontSize: 10, color: AppColors.lightSage)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                  value: _currentStress / 100,
                  minHeight: 10,
                  backgroundColor: AppColors.cardCream.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(_stressColor),
                )),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Live Stress Graph ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Text('Live Stress Graph', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Spacer(),
                Text('Last 20 sec', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
              const SizedBox(height: 16),
              SizedBox(height: 150, child: LineChart(LineChartData(
                minX: minX, maxX: maxX, minY: 0, maxY: 100,
                clipData: const FlClipData.all(),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.sageGreen.withOpacity(0.15), strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 25,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)))),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [LineChartBarData(
                  spots: _liveData, isCurved: true, curveSmoothness: 0.3,
                  color: AppColors.gold, barWidth: 2.5, isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.gold.withOpacity(0.3), AppColors.gold.withOpacity(0.0)],
                  )),
                )],
              ), duration: const Duration(milliseconds: 200))),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Meditation Timer ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _meditating ? AppColors.darkGreen : AppColors.cardCream,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(children: [
              Row(children: [
                Text('🧘', style: TextStyle(fontSize: _meditating ? 28 : 22)),
                const SizedBox(width: 10),
                Text('Meditation Timer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _meditating ? AppColors.cardCream : AppColors.textDark)),
                const Spacer(),
                if (_meditating) Text('5:00 goal', style: TextStyle(fontSize: 11, color: AppColors.lightSage)),
              ]),
              if (_meditating) ...[
                const SizedBox(height: 20),
                // Breathing circle
                ScaleTransition(scale: _breathAnim, child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightSage.withOpacity(0.5), width: 2),
                    color: AppColors.cardCream.withOpacity(0.1)),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_formatTime(_meditationSeconds), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.cardCream)),
                    const Text('breathe...', style: TextStyle(fontSize: 10, color: AppColors.lightSage)),
                  ])),
                )),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                  value: _meditationSeconds / _meditationGoal,
                  minHeight: 6,
                  backgroundColor: AppColors.cardCream.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.safeGreen),
                )),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: OutlinedButton(
                  onPressed: _stopMeditation,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.cardCream, side: BorderSide(color: AppColors.lightSage.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Stop Session', style: TextStyle(fontWeight: FontWeight.w600)),
                )),
              ] else ...[
                const SizedBox(height: 12),
                Text('Start a 5-minute guided breathing session to reduce stress.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: _startMeditation,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen, foregroundColor: AppColors.cardCream, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('🌿', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Start Meditation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ]),
                )),
              ],
            ]),
          ),

          const SizedBox(height: 16),

          // ── Weekly Stress Chart ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Weekly Stress Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              const Text('Average daily stress index this week', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              SizedBox(height: 130, child: BarChart(BarChartData(
                maxY: 100, minY: 0,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.sageGreen.withOpacity(0.15), strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final day = _weekly[v.toInt()]['day'] as String;
                    return Padding(padding: const EdgeInsets.only(top: 4), child: Text(day, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)));
                  })),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(_weekly.length, (i) {
                  final val = _weekly[i]['avg'] as double;
                  final color = val < 30 ? AppColors.safeGreen : val < 55 ? AppColors.alertOrange : AppColors.alertRed;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: val, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [color.withOpacity(0.5), color])),
                  ]);
                }),
              ))),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _legendDot(AppColors.safeGreen, 'Low'),
                _legendDot(AppColors.alertOrange, 'Moderate'),
                _legendDot(AppColors.alertRed, 'High'),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Stress Triggers Log ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Today\'s Stress Triggers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              const Text('Events that affected your stress level today', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 14),
              ..._triggers.map((t) => _triggerRow(t)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _triggerRow(Map<String, dynamic> t) {
    final level = t['level'] as double;
    final color = level < 30 ? AppColors.safeGreen : level < 55 ? AppColors.alertOrange : AppColors.alertRed;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Text(t['emoji'] as String, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t['trigger'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text(t['time'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Text('${level.toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
    ]);
  }
}
