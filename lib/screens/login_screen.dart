import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '+91';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+91',  'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1',   'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44',  'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+61',  'flag': '🇦🇺', 'name': 'Australia'},
    {'code': '+49',  'flag': '🇩🇪', 'name': 'Germany'},
    {'code': '+81',  'flag': '🇯🇵', 'name': 'Japan'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final phoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}';

    await authService.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phoneNumber)));
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sageGreen.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),

                        // ── Logo & Brand ──
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.darkGreen,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkGreen.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🛡', style: TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SHEild',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkGreen,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  'Predict. Protect. Empower.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // ── Headline ──
                        const Text(
                          'Welcome\nback 👋',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Log in with your phone number to continue\nkeeping yourself safe.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Phone Input Label ──
                        const Text(
                          'PHONE NUMBER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Phone Input ──
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardCream,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppColors.sageGreen.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkGreen.withOpacity(0.07),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Country Code
                              PopupMenuButton<String>(
                                initialValue: _selectedCountryCode,
                                color: AppColors.cardCream,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                onSelected: (val) =>
                                    setState(() => _selectedCountryCode = val),
                                itemBuilder: (context) => _countryCodes
                                    .map((c) => PopupMenuItem(
                                          value: c['code'],
                                          child: Row(
                                            children: [
                                              Text(c['flag']!,
                                                  style: const TextStyle(
                                                      fontSize: 18)),
                                              const SizedBox(width: 10),
                                              Text(
                                                '${c['name']}  ${c['code']}',
                                                style: const TextStyle(
                                                  color: AppColors.textDark,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        _countryCodes.firstWhere((c) =>
                                            c['code'] ==
                                            _selectedCountryCode)['flag']!,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedCountryCode,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textMuted, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: AppColors.sageGreen.withOpacity(0.4),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '9876543210',
                                    hintStyle: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 20),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (val.length < 10) {
                                      return 'Enter a valid 10-digit number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'We\'ll send a one-time password to verify your identity.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Login Button ──
                        Consumer<AuthService>(
                          builder: (context, auth, _) => SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _sendOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkGreen,
                                foregroundColor: AppColors.cardCream,
                                disabledBackgroundColor:
                                    AppColors.sageGreen.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 6,
                                shadowColor:
                                    AppColors.darkGreen.withOpacity(0.4),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: AppColors.cardCream,
                                          strokeWidth: 2.5),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Send OTP',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded,
                                            size: 20),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Divider ──
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppColors.sageGreen.withOpacity(0.35),
                                    thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Don\'t have an account?',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppColors.sageGreen.withOpacity(0.35),
                                    thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Sign Up Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignupScreen()));
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkGreen,
                              side: BorderSide(
                                  color: AppColors.darkGreen.withOpacity(0.6),
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Create New Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Feature Pills ──
                        Row(
                          children: [
                            _featurePill('🤖', 'AI Protection'),
                            const SizedBox(width: 8),
                            _featurePill('📍', 'Live GPS'),
                            const SizedBox(width: 8),
                            _featurePill('👥', 'Guardians'),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── Privacy Note ──
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.sageGreen.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  color: AppColors.darkGreen, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your number is used only for authentication and emergency alerts. We never share your data.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featurePill(String icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.sageGreen.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
