import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Listen to auth status changes AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().addListener(_onAuthStatusChanged);
    });
  }

  void _onAuthStatusChanged() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    print('🔔 Login screen - Status changed: ${auth.status}');

    if (auth.status == AuthStatus.otpSent) {
      Navigator.pushNamed(context, '/otp');
    } else if (auth.status == AuthStatus.authenticated) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (auth.status == AuthStatus.profileIncomplete) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/complete-profile', (route) => false);
    } else if (auth.status == AuthStatus.error) {
      _showError(auth.errorMessage);
      auth.resetError();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    // Remove listener to prevent memory leaks
    if (mounted) {
      context.read<AuthProvider>().removeListener(_onAuthStatusChanged);
    }
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Please enter a valid 10-digit number';
    }
    return null;
  }

  void _sendOTP() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final raw = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final phone = '+91$raw';

    print('📱 Sending OTP to: $phone');

    // Fire and forget — listener handles navigation
    context.read<AuthProvider>().sendOTP(phone);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Blood drop icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🩸', style: TextStyle(fontSize: 56)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Title
                  Text(
                    'Welcome to\nBloodBridge',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter your mobile number to continue.\nWe\'ll send you a one-time password.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // Phone label
                  Text(
                    'Mobile Number',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),

                  // Phone input
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    enabled: !isLoading,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validatePhone,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '98765 43210',
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(left: 16, right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Send OTP Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _sendOTP,
                    child: isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Sending OTP...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : const Text('Send OTP'),
                  ),
                  const SizedBox(height: 24),

                  // Terms
                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Impact banner
                  _buildImpactBanner(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImpactBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            '💉  Did you know?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Every 2 seconds someone in India needs blood. One donation can save up to 3 lives.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}