import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    print('🔵 LoginScreen initState');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    // Auto-navigate if already authenticated
    if (authState.isAuthenticated) {
      print('🔵 LoginScreen: Already authenticated, navigating to home');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    // Listen for authentication state changes and navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.isAuthenticated && mounted) {
        print('🔵 LoginScreen: Authentication successful, navigating to home');
        context.go('/');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                // Logo and title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.business_center,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your expo journey',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.grey600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                // Form fields
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 8),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                // Error message
                if (authState.error != null)
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
                // Login button
                CustomButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            print('🔵 LoginScreen: Attempting login');
                            await authNotifier.login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                            // Navigation will happen via the postFrameCallback
                          }
                        },
                  text: 'Sign In',
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 16),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
                // Debug info
                if (authState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Logging in...',
                      style: TextStyle(color: AppColors.grey600),
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