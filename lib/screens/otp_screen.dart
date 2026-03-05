import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? userName;
  final String? emergencyContact;
  final String? emergencyName;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.userName,
    this.emergencyContact,
    this.emergencyName,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  int _secondsLeft = 60;
  bool _canResend = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

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
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) _canResend = true;
      });
      return _secondsLeft > 0;
    });
  }

  void _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Please enter the complete 6-digit OTP'),
          ],
        ),
        backgroundColor: AppColors.alertRed,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.verifyOTP(_otpController.text);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Invalid OTP. Please try again.'),
          ],
        ),
        backgroundColor: AppColors.alertRed,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPin = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageGreen.withOpacity(0.4)),
      ),
    );

    final focusedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkGreen, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );

    final submittedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: AppColors.sageGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageGreen),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🔐', style: TextStyle(fontSize: 30)),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: 'We sent a 6-digit verification\ncode to '),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input
                Center(
                  child: Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: defaultPin,
                    focusedPinTheme: focusedPin,
                    submittedPinTheme: submittedPin,
                    onCompleted: (_) => _verifyOTP(),
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                  ),
                ),

                const SizedBox(height: 32),

                // Resend timer
                Center(
                  child: _canResend
                      ? GestureDetector(
                          onTap: _startTimer,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.sageGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.sageGreen.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh_rounded,
                                    color: AppColors.darkGreen, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: AppColors.darkGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Resend in ',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14)),
                            Text(
                              '0:${_secondsLeft.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),

                const Spacer(),

                // Verify button
                Consumer<AuthService>(
                  builder: (context, auth, _) => SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _verifyOTP,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Verify & Continue',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
