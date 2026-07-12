import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'visitor';
  bool _agreeToTerms = false;
  final Logger _logger = Logger();

  final List<String> _roles = [
    'visitor',
    'exhibitor',
    'organizer',
    'sponsor',
    'speaker',
    'investor',
  ];

  @override
  void initState() {
    super.initState();
    _logger.i('🔵 RegisterScreen initState');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    // Auto-navigate if already authenticated
    if (authState.isAuthenticated) {
      _logger.i('🔵 RegisterScreen: Already authenticated, navigating to home');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    // Listen for authentication state changes and navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.isAuthenticated && mounted) {
        _logger.i('🔵 RegisterScreen: Registration successful, navigating to home');
        context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    'Join ExpoConnect',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account to start networking',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Name fields
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _firstNameController,
                          label: 'First Name *',
                          hintText: 'Enter first name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'First name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _lastNameController,
                          label: 'Last Name *',
                          hintText: 'Enter last name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Last name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email *',
                    hintText: 'Enter your email address',
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone (Optional)',
                    hintText: '+1234567890',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  // Role dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.grey50,
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password *',
                    hintText: 'Min 6 characters with letters and numbers',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                        return 'Password must contain at least one letter and one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm password
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password *',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Terms and Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
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
                  
                  // Register button
                  CustomButton(
                    onPressed: authState.isLoading
                        ? null
                        : () async {
                            if (!_agreeToTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please agree to the Terms of Service'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                              return;
                            }
                            
                            if (_formKey.currentState?.validate() ?? false) {
                              // Log the registration data
                              final data = {
                                'firstName': _firstNameController.text.trim(),
                                'lastName': _lastNameController.text.trim(),
                                'email': _emailController.text.trim().toLowerCase(),
                                'password': _passwordController.text.trim(),
                                'phone': _phoneController.text.trim().isEmpty 
                                    ? null 
                                    : _phoneController.text.trim(),
                                'role': _selectedRole,
                              };
                              _logger.i('📝 Registering with data: ${jsonEncode(data)}');
                              
                              await authNotifier.register(
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                email: _emailController.text.trim().toLowerCase(),
                                password: _passwordController.text.trim(),
                                phone: _phoneController.text.trim().isEmpty 
                                    ? null 
                                    : _phoneController.text.trim(),
                                role: _selectedRole,
                              );
                              // Navigation will happen via the postFrameCallback
                            }
                          },
                    text: 'Create Account',
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Debug info
                  if (authState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Creating account...',
                        style: TextStyle(color: AppColors.grey600),
                      ),
                    ),
                  if (authState.error != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Debug: ${authState.error}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}