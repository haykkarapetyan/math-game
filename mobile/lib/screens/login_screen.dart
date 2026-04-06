import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../providers/game_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.login(email, password);
      final user = data['user'];
      ref.read(playerProvider.notifier).login(
        user['username'] ?? '',
        user['email'] ?? '',
      );
      if (mounted) context.go('/tiers');
    } catch (_) {
      setState(() => _error = 'Invalid email or password');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo area
              const Center(
                child: Column(
                  children: [
                    Text('\u{1F9EE}',
                        style: TextStyle(fontSize: 64)),
                    SizedBox(height: 12),
                    Text('Math Crossword',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        )),
                    SizedBox(height: 4),
                    Text('Train your brain',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5D7B9A),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Password', Icons.lock_outlined)
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF90A4AE),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?',
                      style: TextStyle(color: Color(0xFF3D5AFE))),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),
              ],
              const SizedBox(height: 16),
              // Login button
              FilledButton(
                onPressed: _loading ? null : _login,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Login',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
              // Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or',
                        style: TextStyle(color: Color(0xFF90A4AE))),
                  ),
                  Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                ],
              ),
              const SizedBox(height: 24),
              // Social login buttons
              OutlinedButton.icon(
                onPressed: _login,
                icon: const Text('\u{1F310}', style: TextStyle(fontSize: 20)),
                label: const Text('Continue with Google'),
                style: _socialButtonStyle(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _login,
                icon: const Text('\u{F8FF}', style: TextStyle(fontSize: 20)),
                label: const Text('Continue with Apple'),
                style: _socialButtonStyle(),
              ),
              const SizedBox(height: 24),
              // Skip login
              TextButton(
                onPressed: () {
                  ref.read(playerProvider.notifier).login('Guest', 'guest@mathgame.app');
                  context.go('/tiers');
                },
                child: const Text('Skip, play as guest',
                    style: TextStyle(
                        color: Color(0xFF90A4AE), fontSize: 15)),
              ),
              const SizedBox(height: 8),
              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                      style: TextStyle(color: Color(0xFF5D7B9A))),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text('Sign up',
                        style: TextStyle(
                          color: Color(0xFF3D5AFE),
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF90A4AE)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3D5AFE), width: 2),
      ),
    );
  }

  ButtonStyle _socialButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF2C3E50),
      side: const BorderSide(color: Color(0xFFE0E0E0)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
