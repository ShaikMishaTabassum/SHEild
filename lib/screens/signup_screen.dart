import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Step 1 — Profile
  final _nameController = TextEditingController();
  String _selectedGender = 'Female';
  DateTime? _dateOfBirth;

  // Step 2 — Phone
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';

  // Step 3 — Guardian
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  String _guardianRelation = 'Mother';

  final List<String> _genders = ['Female', 'Non-binary', 'Prefer not to say'];
  final List<String> _relations = [
    'Mother', 'Father', 'Sister', 'Brother',
    'Friend', 'Husband', 'Partner', 'Other'
  ];
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91',  'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1',   'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44',  'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+61',  'flag': '🇦🇺', 'name': 'Australia'},
  ];

  final List<Map<String, dynamic>> _steps = [
    {'icon': '👤', 'title': 'Profile', 'subtitle': 'Who are you?'},
    {'icon': '📱', 'title': 'Phone', 'subtitle': 'Your number'},
    {'icon': '👥', 'title': 'Guardian', 'subtitle': 'Emergency contact'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your full name');
        return;
      }
    } else if (_currentStep == 1) {
      if (_phoneController.text.trim().length < 10) {
        _showError('Please enter a valid 10-digit phone number');
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitSignup();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(msg),
        ],
      ),
      backgroundColor: AppColors.alertRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _submitSignup() async {
    if (_guardianNameController.text.trim().isEmpty ||
        _guardianPhoneController.text.trim().length < 10) {
      _showError('Please fill in guardian details');
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final phoneNumber =
        '$_selectedCountryCode${_phoneController.text.trim()}';

    await authService.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: phoneNumber,
              userName: _nameController.text.trim(),
              emergencyContact:
                  '+91${_guardianPhoneController.text.trim()}',
              emergencyName: _guardianNameController.text.trim(),
            ),
          ),
        );
      },
      onError: (error) => _showError(error),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkGreen,
              onPrimary: AppColors.cardCream,
              surface: AppColors.cardCream,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sageGreen.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    children: [
                      // Nav row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _prevStep,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.cardCream,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                    color: AppColors.sageGreen
                                        .withOpacity(0.3)),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.textDark,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.darkGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text('🛡',
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SHEild',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGreen,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Step ${_currentStep + 1} of 3',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Account',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _steps[_currentStep]['subtitle'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Step Indicators ──
                      Row(
                        children: List.generate(_steps.length, (i) {
                          final isActive = i == _currentStep;
                          final isDone = i < _currentStep;
                          return Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isDone || isActive
                                          ? AppColors.darkGreen
                                          : AppColors.lightSage
                                              .withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                if (i < _steps.length - 1)
                                  const SizedBox(width: 6),
                              ],
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 12),

                      // Step labels
                      Row(
                        children: List.generate(_steps.length, (i) {
                          final isActive = i == _currentStep;
                          final isDone = i < _currentStep;
                          return Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _steps[i]['title'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isActive || isDone
                                          ? AppColors.darkGreen
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                if (i < _steps.length - 1)
                                  const SizedBox(width: 6),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // ── Page Content ──
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                    ],
                  ),
                ),

                // ── Bottom Button ──
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 12, 24, 28),
                  child: Consumer<AuthService>(
                    builder: (context, auth, _) => SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: AppColors.cardCream,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 6,
                          shadowColor: AppColors.darkGreen.withOpacity(0.4),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: AppColors.cardCream,
                                    strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentStep == 2
                                        ? 'Create Account'
                                        : 'Continue',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentStep == 2
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Profile ───────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('FULL NAME'),
          const SizedBox(height: 8),
          _textField(
            controller: _nameController,
            hint: 'e.g. Misha Tabassum',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
          ),

          const SizedBox(height: 24),
          _label('DATE OF BIRTH'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.sageGreen.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined,
                      color: AppColors.darkGreen, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _dateOfBirth == null
                        ? 'Select your date of birth'
                        : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                    style: TextStyle(
                      fontSize: 15,
                      color: _dateOfBirth == null
                          ? AppColors.textMuted
                          : AppColors.textDark,
                      fontWeight: _dateOfBirth == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _label('GENDER'),
          const SizedBox(height: 8),
          Row(
            children: _genders.map((g) {
              final isSelected = g == _selectedGender;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: g != _genders.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.darkGreen
                          : AppColors.cardCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.darkGreen
                            : AppColors.sageGreen.withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      g,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.cardCream
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          _infoCard(
            Icons.shield_outlined,
            'Your profile helps us tailor safety alerts and health insights specifically for you.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Step 2: Phone ─────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('PHONE NUMBER'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.sageGreen.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
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
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Text(
                                  '${c['name']}  ${c['code']}',
                                  style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 14),
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
                              c['code'] == _selectedCountryCode)['flag']!,
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
                    color: AppColors.sageGreen.withOpacity(0.4)),
                Expanded(
                  child: TextField(
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
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _infoCard(
            Icons.sms_outlined,
            'We\'ll send a one-time password to verify this number. This will also be used for emergency SOS alerts.',
          ),

          const SizedBox(height: 24),

          // What happens next card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What happens next?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cardCream,
                  ),
                ),
                const SizedBox(height: 16),
                _nextStepRow('1', 'Verify your phone with OTP'),
                const SizedBox(height: 10),
                _nextStepRow('2', 'Set up your guardian contacts'),
                const SizedBox(height: 10),
                _nextStepRow('3', 'Start using SHEild safely'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Step 3: Guardian ──────────────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('GUARDIAN\'S NAME'),
          const SizedBox(height: 8),
          _textField(
            controller: _guardianNameController,
            hint: 'e.g. Sarah J.',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
          ),

          const SizedBox(height: 20),
          _label('GUARDIAN\'S PHONE'),
          const SizedBox(height: 8),
          _textField(
            controller: _guardianPhoneController,
            hint: '9876543210',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            prefix: '+91 ',
          ),

          const SizedBox(height: 20),
          _label('RELATIONSHIP'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _relations.map((r) {
              final isSelected = r == _guardianRelation;
              return GestureDetector(
                onTap: () => setState(() => _guardianRelation = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.darkGreen
                        : AppColors.cardCream,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.darkGreen
                          : AppColors.sageGreen.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.cardCream
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          _infoCard(
            Icons.favorite_outline_rounded,
            'Your guardian will receive an SMS alert with your live location when SOS is triggered. You can add more guardians after signing up.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
          letterSpacing: 1.5,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    String? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageGreen.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(icon, color: AppColors.darkGreen, size: 20),
          ),
          if (prefix != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                prefix,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextStepRow(String num, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.lightSage,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
