import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<FlSpot> _liveData = [];
  double _currentBPM = 73;
  double _minBPM = 62;
  double _maxBPM = 73;
  int _tick = 0;
  bool _alertSent = false;
  late Timer _dataTimer;
  final Random _random = Random();

  // History: last 7 days avg BPM
  final List<Map<String, dynamic>> _history = [
    {'day': 'Mon', 'avg': 71.0},
    {'day': 'Tue', 'avg': 74.0},
    {'day': 'Wed', 'avg': 68.0},
    {'day': 'Thu', 'avg': 78.0},
    {'day': 'Fri', 'avg': 72.0},
    {'day': 'Sat', 'avg': 65.0},
    {'day': 'Sun', 'avg': 73.0},
  ];

  // Heart rate zones
  String get _zone {
    if (_currentBPM < 60) return 'Below Rest';
    if (_currentBPM < 70) return 'Resting';
    if (_currentBPM < 85) return 'Light';
    if (_currentBPM < 100) return 'Cardio';
    return 'Peak';
  }

  Color get _zoneColor {
    if (_currentBPM < 60) return const Color(0xFF64B5F6);
    if (_currentBPM < 70) return AppColors.safeGreen;
    if (_currentBPM < 85) return const Color(0xFF81C784);
    if (_currentBPM < 100) return AppColors.alertOrange;
    return AppColors.alertRed;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    for (int i = 0; i < 20; i++) {
      final v = 68 + _random.nextDouble() * 10;
      _liveData.add(FlSpot(i.toDouble(), v));
    }
    _tick = 20;

    _dataTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _tick++;
        _currentBPM = (_currentBPM + (_random.nextDouble() - 0.45) * 5).clamp(55, 125);
        if (_currentBPM < _minBPM) _minBPM = _currentBPM;
        if (_currentBPM > _maxBPM) _maxBPM = _currentBPM;
        _liveData.add(FlSpot(_tick.toDouble(), _currentBPM));
        if (_liveData.length > 20) _liveData.removeAt(0);

        // Doctor alert
        if (_currentBPM > 110 && !_alertSent) {
          _alertSent = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _showDoctorAlert();
          });
        }
        if (_currentBPM < 105) _alertSent = false;
      });
    });
  }

  void _showDoctorAlert() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.alertRed.withOpacity(0.2), blurRadius: 20)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.alertRed.withOpacity(0.1), shape: BoxShape.circle),
            child: const Center(child: Text('🚨', style: TextStyle(fontSize: 30)))),
          const SizedBox(height: 14),
          const Text('High Heart Rate Alert!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.alertRed)),
          const SizedBox(height: 8),
          Text('Your BPM is ${_currentBPM.toStringAsFixed(0)} — above the safe threshold of 110.\nPlease rest immediately.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.darkGreen, side: const BorderSide(color: AppColors.sageGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Dismiss'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Call Doctor', style: TextStyle(fontWeight: FontWeight.w800)))),
          ]),
        ]),
      ),
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dataTimer.cancel();
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
        title: const Text('Heart Rate', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 20)),
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

          // ── Current BPM Hero Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('CURRENT BPM', style: TextStyle(fontSize: 10, color: AppColors.lightSage, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_currentBPM.toStringAsFixed(0), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.cardCream, height: 1)),
                    const Padding(padding: EdgeInsets.only(bottom: 8, left: 6), child: Text('BPM', style: TextStyle(fontSize: 18, color: AppColors.lightSage, fontWeight: FontWeight.w500))),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: _zoneColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: _zoneColor.withOpacity(0.5))),
                    child: Text(_zone, style: TextStyle(fontSize: 12, color: _zoneColor, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const Spacer(),
                ScaleTransition(scale: _pulseAnim, child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppColors.cardCream.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Text('❤️', style: TextStyle(fontSize: 42))),
                )),
              ]),
              const SizedBox(height: 20),
              // Min / Max row
              Row(children: [
                Expanded(child: _statChip('MIN TODAY', '${_minBPM.toStringAsFixed(0)} BPM', Icons.arrow_downward_rounded, const Color(0xFF64B5F6))),
                const SizedBox(width: 10),
                Expanded(child: _statChip('MAX TODAY', '${_maxBPM.toStringAsFixed(0)} BPM', Icons.arrow_upward_rounded, AppColors.alertOrange)),
                const SizedBox(width: 10),
                Expanded(child: _statChip('RESTING', '65 BPM', Icons.horizontal_rule_rounded, AppColors.safeGreen)),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Live Graph ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Text('Live Heart Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Spacer(),
                Text('Last 20 sec', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
              const SizedBox(height: 16),
              SizedBox(height: 160, child: LineChart(LineChartData(
                minX: minX, maxX: maxX, minY: 50, maxY: 130,
                clipData: const FlClipData.all(),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.sageGreen.withOpacity(0.15), strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 20,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)))),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [LineChartBarData(
                  spots: _liveData, isCurved: true, curveSmoothness: 0.25,
                  color: const Color(0xFFEF9A9A), barWidth: 2.5, isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [const Color(0xFFE57373).withOpacity(0.3), const Color(0xFFE57373).withOpacity(0.0)],
                  )),
                )],
              ), duration: const Duration(milliseconds: 200))),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Heart Rate Zones ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Heart Rate Zones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 14),
              _zoneBar('Below Rest', '< 60', const Color(0xFF64B5F6), _currentBPM < 60),
              _zoneBar('Resting', '60–70', AppColors.safeGreen, _currentBPM >= 60 && _currentBPM < 70),
              _zoneBar('Light Activity', '70–85', const Color(0xFF81C784), _currentBPM >= 70 && _currentBPM < 85),
              _zoneBar('Cardio', '85–100', AppColors.alertOrange, _currentBPM >= 85 && _currentBPM < 100),
              _zoneBar('Peak', '> 100', AppColors.alertRed, _currentBPM >= 100),
            ]),
          ),

          const SizedBox(height: 16),

          // ── 7 Day History ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('7-Day Average', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              const Text('Daily average BPM over the past week', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              SizedBox(height: 120, child: BarChart(BarChartData(
                maxY: 100, minY: 0,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.sageGreen.withOpacity(0.15), strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final day = _history[v.toInt()]['day'] as String;
                    return Padding(padding: const EdgeInsets.only(top: 4), child: Text(day, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)));
                  })),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(_history.length, (i) => BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: (_history[i]['avg'] as double), width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [AppColors.darkGreen.withOpacity(0.6), AppColors.midGreen])),
                ])),
              ))),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _history.map((h) => Column(children: [
                Text('${(h['avg'] as double).toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text(h['day'] as String, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
              ])).toList()),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Doctor Alert Info ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.alertRed.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.alertRed.withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.alertRed.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('🩺', style: TextStyle(fontSize: 22)))),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Doctor Alert Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.alertRed)),
                SizedBox(height: 3),
                Text('You will be alerted automatically if BPM exceeds 110. Stay safe!', style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4)),
              ])),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: AppColors.cardCream.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 8, color: AppColors.lightSage, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cardCream)),
      ]),
    );
  }

  Widget _zoneBar(String label, String range, Color color, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? color.withOpacity(0.4) : Colors.transparent),
      ),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? color : AppColors.textMuted)),
        const Spacer(),
        Text(range, style: TextStyle(fontSize: 11, color: isActive ? color : AppColors.textMuted, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
        if (isActive) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text('NOW', style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w800)))],
      ]),
    );
  }
}


