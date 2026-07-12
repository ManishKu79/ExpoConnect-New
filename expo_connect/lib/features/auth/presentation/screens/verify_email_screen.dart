import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                'We sent a verification link to your email address. Please click the link to verify your account.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey600,
                    ),
                textAlign: TextAlign.center,
              ),
              if (widget.email != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.email!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              // Resend button
              CustomButton(
                onPressed: _isResending
                    ? null
                    : () async {
                        setState(() {
                          _isResending = true;
                        });
                        // TODO: Implement resend verification email
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          _isResending = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification email resent'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                text: 'Resend Verification Email',
                isLoading: _isResending,
                isOutlined: true,
              ),
              const SizedBox(height: 16),
              // Already verified
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Already verified? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}