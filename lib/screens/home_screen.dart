import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'health_dashboard_screen.dart';
import 'heart_screen.dart';
import 'stress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;

  // Live BPM + stress for home tab preview
  double _currentBPM = 73;
  double _currentStress = 28;
  late Timer _dataTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _dataTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _currentBPM = (_currentBPM + (_random.nextDouble() - 0.45) * 4).clamp(58, 115);
        _currentStress = (_currentStress + (_random.nextDouble() - 0.45) * 3).clamp(10, 85);
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _dataTimer.cancel();
    super.dispose();
  }

  String get _stressLabel => _currentStress < 30 ? 'LOW' : _currentStress < 55 ? 'MODERATE' : 'HIGH';
  Color get _stressColor => _currentStress < 30 ? AppColors.safeGreen : _currentStress < 55 ? AppColors.alertOrange : AppColors.alertRed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeTab(),
          const HeartRateScreen(),
          const StressScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, 'Home'),
                _navItem(1, Icons.favorite_rounded, 'Heart'),
                _navItem(2, Icons.psychology_rounded, 'Stress'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentTab == index;
    Color iconColor = icon == Icons.favorite_rounded
        ? const Color(0xFFE57373)
        : icon == Icons.psychology_rounded
            ? AppColors.gold
            : AppColors.darkGreen;

    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? iconColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isActive ? iconColor : AppColors.textMuted, size: 24),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? iconColor : AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: AppColors.darkGreen, borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('🛡', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          const Text('SHEild', style: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 1.5)),
        ]),
        actions: [
          IconButton(
            icon: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.sageGreen.withOpacity(0.3))),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.darkGreen, size: 20),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.darkGreen, size: 22),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Safety Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('SAFETY STATUS:', style: TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(children: [
                      ScaleTransition(scale: _pulseAnim, child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.safeGreen, shape: BoxShape.circle))),
                      const SizedBox(width: 8),
                      const Text('SAFE', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 1)),
                    ]),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.alertRed.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.alertRed.withOpacity(0.3))),
                    child: const Column(children: [
                      Text('⚠️', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 2),
                      Text('HIGH RISK AREA', style: TextStyle(fontSize: 8, color: AppColors.alertRed, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      Text('DETECTED', style: TextStyle(fontSize: 8, color: AppColors.alertRed, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FakeMapWidget(height: 100, showRoute: false),
                    const SizedBox(height: 6),
                    const Row(children: [
                      Icon(Icons.location_on_rounded, color: AppColors.darkGreen, size: 12),
                      SizedBox(width: 4),
                      Text('LIVE LOCATION', style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ]),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: Column(children: [
                    ScaleTransition(scale: _pulseAnim, child: GestureDetector(
                      onTap: () => _showSOSConfirm(context),
                      child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.cardCream,
                          border: Border.all(color: AppColors.sageGreen.withOpacity(0.4), width: 3),
                          boxShadow: [BoxShadow(color: AppColors.alertRed.withOpacity(0.15), blurRadius: 20, spreadRadius: 4)],
                        ),
                        child: const Center(child: Text('SOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.alertRed, letterSpacing: 1))),
                      ),
                    )),
                    const SizedBox(height: 6),
                    const Text('TAP 3 TIMES ON\nBAND TO TRIGGER', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: AppColors.textMuted, height: 1.4)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FakeMapWidget(height: 100, showRoute: true),
                    const SizedBox(height: 6),
                    const Row(children: [
                      Icon(Icons.route_rounded, color: AppColors.safeGreen, size: 12),
                      SizedBox(width: 4),
                      Flexible(child: Text('SUGGESTED SAFER ROUTE', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.3))),
                    ]),
                  ])),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.mic_rounded, color: AppColors.darkGreen, size: 16),
                    const SizedBox(width: 8),
                    const Text('Voice activated SOS — say "Help me"', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const Spacer(),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.safeGreen, shape: BoxShape.circle)),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 14),

            // ── Live Vitals Preview Row ──
            Row(children: [
              // Heart Rate mini card
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _currentTab = 1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('❤️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      const Text('HEART', style: TextStyle(fontSize: 9, color: AppColors.lightSage, letterSpacing: 1, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.safeGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.safeGreen, shape: BoxShape.circle)),
                          const SizedBox(width: 3),
                          const Text('LIVE', style: TextStyle(fontSize: 7, color: AppColors.safeGreen, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_currentBPM.toStringAsFixed(0), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.cardCream, height: 1)),
                      const Padding(padding: EdgeInsets.only(bottom: 3, left: 3), child: Text('BPM', style: TextStyle(fontSize: 10, color: AppColors.lightSage))),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      _currentBPM > 100 ? 'Elevated ↑' : _currentBPM < 65 ? 'Low ↓' : 'Normal ✓',
                      style: TextStyle(fontSize: 10, color: _currentBPM > 100 ? AppColors.alertOrange : AppColors.safeGreen, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap for full analysis →', style: TextStyle(fontSize: 9, color: AppColors.lightSage)),
                  ]),
                ),
              )),

              const SizedBox(width: 12),

              // Stress mini card
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _currentTab = 2),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('🧠', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      const Text('STRESS', style: TextStyle(fontSize: 9, color: AppColors.textMuted, letterSpacing: 1, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.safeGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.safeGreen, shape: BoxShape.circle)),
                          const SizedBox(width: 3),
                          const Text('LIVE', style: TextStyle(fontSize: 7, color: AppColors.safeGreen, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_currentStress.toStringAsFixed(0), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1)),
                      const Padding(padding: EdgeInsets.only(bottom: 3, left: 3), child: Text('%', style: TextStyle(fontSize: 10, color: AppColors.textMuted))),
                    ]),
                    const SizedBox(height: 4),
                    Text(_stressLabel, style: TextStyle(fontSize: 10, color: _stressColor, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Tap for full analysis →', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                  ]),
                ),
              )),
            ]),

            const SizedBox(height: 14),

            // ── Health Dashboard ──
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthDashboardScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text('Health Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    SizedBox(width: 90, height: 90, child: CustomPaint(
                      painter: _CyclePainter(),
                      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('PERIOD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('OVULATION', style: TextStyle(fontSize: 7, color: AppColors.textMuted)),
                      ])),
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _guardianAvatar('👩🏽', 'Mom'),
                      _guardianAvatar('👩🏻', 'Best Friend'),
                      _guardianAvatar('👨🏽', 'Husband'),
                    ])),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Text('Next Period: +5 Days', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const Spacer(),
                    Icon(Icons.mic_outlined, color: AppColors.sageGreen, size: 18),
                  ]),
                ]),
              ),
            ),

            const SizedBox(height: 14),

            // ── Stress Trend + Guardian ──
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('STRESS TREND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  SizedBox(height: 70, child: CustomPaint(painter: _StressCurvePainter(), size: const Size(double.infinity, 70))),
                  const SizedBox(height: 6),
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('0', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                    Text('20', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                    Text('30', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                    Text('40', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                  ]),
                ]),
              )),
              const SizedBox(width: 12),
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.darkGreen.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Guardian Network', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _guardianNetworkRow('👩🏽', 'Sarah J.', '0.5 km'),
                  const SizedBox(height: 10),
                  _guardianNetworkRow('👨🏽', 'David K.', '1.2 km'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showRequestHelpDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.sageGreen.withOpacity(0.4))),
                      child: const Center(child: Text('REQUEST HELP NOW >', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkGreen, letterSpacing: 0.5))),
                    ),
                  ),
                ]),
              )),
            ]),

            const SizedBox(height: 14),

            // ── AI Insights ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sageGreen.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Text('🤖', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('AI INSIGHTS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(
                    _currentStress > 55 ? 'High stress detected. Try deep breathing for 5 min.' : _currentBPM > 95 ? 'Elevated heart rate. Rest and hydrate.' : 'All vitals normal. Stay hydrated today.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                  ),
                ])),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _showSOSConfirm(BuildContext context) {
    showDialog(context: context, builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🚨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Send SOS Alert?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('This will send your live location to all guardians immediately.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppColors.darkGreen, side: const BorderSide(color: AppColors.sageGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text('SEND SOS', style: TextStyle(fontWeight: FontWeight.w800)))),
          ]),
        ]),
      ),
    ));
  }

  void _showRequestHelpDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.cardCream, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('👥', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text('Request Help?', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Sarah J. and David K. will be notified with your location.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen, foregroundColor: AppColors.cardCream, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Send Request', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
        ]),
      ),
    ));
  }

  Widget _guardianAvatar(String emoji, String name) {
    return Column(children: [
      CircleAvatar(radius: 22, backgroundColor: AppColors.sageGreen.withOpacity(0.2), child: Text(emoji, style: const TextStyle(fontSize: 20))),
      const SizedBox(height: 4),
      Text(name, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _guardianNetworkRow(String emoji, String name, String distance) {
    return Row(children: [
      CircleAvatar(radius: 16, backgroundColor: AppColors.sageGreen.withOpacity(0.2), child: Text(emoji, style: const TextStyle(fontSize: 14))),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        Text(distance, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]),
      const Spacer(),
      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.safeGreen, shape: BoxShape.circle)),
    ]);
  }
}

// ── Painters ──────────────────────────────────────────────────────
class _FakeMapWidget extends StatelessWidget {
  final double height;
  final bool showRoute;
  const _FakeMapWidget({required this.height, required this.showRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFFE8E4DC)),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CustomPaint(painter: _MapPainter(showRoute: showRoute), child: showRoute ? const SizedBox() : const Center(child: Icon(Icons.location_on_rounded, color: Color(0xFFD32F2F), size: 24)))),
    );
  }
}

class _MapPainter extends CustomPainter {
  final bool showRoute;
  _MapPainter({required this.showRoute});
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = const Color(0xFFD4CEBC)..strokeWidth = 6..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final building = Paint()..color = const Color(0xFFCDC8B8)..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += size.width / 4) canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    for (double y = 0; y < size.height; y += size.height / 3) canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    for (final b in [
      Rect.fromLTWH(size.width*0.05, size.height*0.05, size.width*0.18, size.height*0.25),
      Rect.fromLTWH(size.width*0.28, size.height*0.05, size.width*0.18, size.height*0.2),
      Rect.fromLTWH(size.width*0.55, size.height*0.05, size.width*0.15, size.height*0.28),
      Rect.fromLTWH(size.width*0.75, size.height*0.05, size.width*0.2,  size.height*0.22),
      Rect.fromLTWH(size.width*0.05, size.height*0.45, size.width*0.2,  size.height*0.45),
      Rect.fromLTWH(size.width*0.3,  size.height*0.5,  size.width*0.15, size.height*0.4),
      Rect.fromLTWH(size.width*0.55, size.height*0.48, size.width*0.18, size.height*0.42),
      Rect.fromLTWH(size.width*0.78, size.height*0.45, size.width*0.17, size.height*0.45),
    ]) canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(3)), building);
    if (showRoute) {
      final rp = Paint()..color = const Color(0xFF4CAF50)..strokeWidth = 3..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      final path = Path()..moveTo(size.width*0.1, size.height*0.9)..cubicTo(size.width*0.2, size.height*0.6, size.width*0.5, size.height*0.7, size.width*0.7, size.height*0.3)..cubicTo(size.width*0.8, size.height*0.15, size.width*0.85, size.height*0.1, size.width*0.9, size.height*0.05);
      canvas.drawPath(path, rp);
      canvas.drawCircle(Offset(size.width*0.9, size.height*0.05), 5, Paint()..color = const Color(0xFF4CAF50));
      canvas.drawCircle(Offset(size.width*0.1, size.height*0.9), 5, Paint()..color = const Color(0xFFE57373));
    }
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

class _CyclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width/2, size.height/2);
    final r = size.width/2 - 6;
    canvas.drawCircle(c, r, Paint()..color = AppColors.lightSage.withOpacity(0.3)..strokeWidth = 8..style = PaintingStyle.stroke);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi/2,       pi*0.35, false, Paint()..color = const Color(0xFFE57373)..strokeWidth = 8..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi/2+pi*0.35, pi*0.2, false, Paint()..color = AppColors.gold..strokeWidth = 8..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi/2+pi*0.55, pi*0.85, false, Paint()..color = AppColors.sageGreen..strokeWidth = 8..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

class _StressCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.sageGreen.withOpacity(0.4), AppColors.sageGreen.withOpacity(0.05)]).createShader(Rect.fromLTWH(0,0,size.width,size.height))..style = PaintingStyle.fill;
    final line = Paint()..color = AppColors.sageGreen..strokeWidth = 2.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final pts = [Offset(0,size.height*0.7),Offset(size.width*0.15,size.height*0.5),Offset(size.width*0.3,size.height*0.6),Offset(size.width*0.45,size.height*0.3),Offset(size.width*0.6,size.height*0.45),Offset(size.width*0.75,size.height*0.25),Offset(size.width*0.85,size.height*0.4),Offset(size.width,size.height*0.35)];
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length-1; i++) {
      final cp1 = Offset((pts[i].dx+pts[i+1].dx)/2, pts[i].dy);
      final cp2 = Offset((pts[i].dx+pts[i+1].dx)/2, pts[i+1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i+1].dx, pts[i+1].dy);
    }
    canvas.drawPath(Path.from(path)..lineTo(size.width,size.height)..lineTo(0,size.height)..close(), fill);
    canvas.drawPath(path, line);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}
