import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Reset Your Password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we will send you instructions to reset your password',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                ),
                const SizedBox(height: 32),
                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your registered email',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                // Success message
                if (_isSubmitted)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Password reset email sent! Please check your inbox.',
                            style: TextStyle(color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (authState.error != null && !_isSubmitted)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Send button
                CustomButton(
                  onPressed: authState.isLoading || _isSubmitted
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              await authNotifier.forgotPassword(
                                _emailController.text.trim(),
                              );
                              setState(() {
                                _isSubmitted = true;
                              });
                            } catch (e) {
                              // Error handled by provider
                            }
                          }
                        },
                  text: 'Send Reset Instructions',
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 16),
                // Back to login
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to Sign In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}