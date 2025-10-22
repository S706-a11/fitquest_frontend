import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../providers/user_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0F),
        elevation: 0,
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name
            TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Name', Icons.person_outline),
            ),
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Email', Icons.email_outlined),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _password,
              obscureText: _obscure1,
              style: const TextStyle(color: Colors.white),
              decoration: _passwordStyle(
                hint: 'Password',
                obscure: _obscure1,
                onToggle: () => setState(() => _obscure1 = !_obscure1),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextField(
              controller: _confirmPassword,
              obscureText: _obscure2,
              style: const TextStyle(color: Colors.white),
              decoration: _passwordStyle(
                hint: 'Confirm Password',
                obscure: _obscure2,
                onToggle: () => setState(() => _obscure2 = !_obscure2),
              ),
            ),
            const SizedBox(height: 16),

            // Weight & Height
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: _numberInputStyle(
                      hint: 'Weight',
                      icon: Icons.monitor_weight_outlined,
                      suffix: 'kg',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _height,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: _numberInputStyle(
                      hint: 'Height',
                      icon: Icons.height,
                      suffix: 'cm',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Sign Up (mock) → Onboarding
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF99),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                        : const Text('Sign Up'),
              ),
            ),

            const SizedBox(height: 18),

            // Back to login
            GestureDetector(
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
              child: const Text(
                "Already have an account? Log In",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Helpers -----

  Future<void> _onSubmit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;
    final confirm = _confirmPassword.text;
    final weightStr = _weight.text.trim();
    final heightStr = _height.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _toast('Please fill all required fields');
      return;
    }

    if (!email.contains('@')) {
      _toast('Please enter a valid email address');
      return;
    }

    if (pass.length < 6) {
      _toast('Password must be at least 6 characters');
      return;
    }

    if (pass != confirm) {
      _toast('Passwords do not match');
      return;
    }

    // Weight and height are optional for registration
    double? weight;
    double? height;

    if (weightStr.isNotEmpty) {
      weight = double.tryParse(weightStr);
      if (weight == null || weight <= 0) {
        _toast('Enter valid weight');
        return;
      }
    }

    if (heightStr.isNotEmpty) {
      height = double.tryParse(heightStr);
      if (height == null || height <= 0) {
        _toast('Enter valid height');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      print('RegisterPage: Starting registration for $name, $email');
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.register(name, email, pass);

      if (!mounted) return;

      print('RegisterPage: Registration result: $success');

      if (success) {
        // Update weight and height if provided
        if ((weight != null && weight > 0) || (height != null && height > 0)) {
          try {
            print(
              'RegisterPage: Updating weight/height - weight: $weight, height: $height',
            );
            await userProvider.refreshUser();
            // You could also call updateUser here if needed
          } catch (e) {
            print('RegisterPage: Could not update weight/height: $e');
          }
        }

        // Navigate to home page on successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
      } else {
        // Show error from provider
        print('RegisterPage: Registration failed - ${userProvider.error}');
        _toast(userProvider.error ?? 'Registration failed');
      }
    } catch (e) {
      print('RegisterPage: Registration exception: $e');
      if (!mounted) return;
      _toast('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1A1A1D),
      prefixIcon: Icon(icon, color: Colors.white54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00FF99), width: 1.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _passwordStyle({
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return _inputStyle(hint, Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility : Icons.visibility_off,
          color: Colors.white54,
        ),
        onPressed: onToggle,
      ),
    );
  }

  InputDecoration _numberInputStyle({
    required String hint,
    required IconData icon,
    required String suffix,
  }) {
    return _inputStyle(hint, icon).copyWith(
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.white70),
    );
  }
}
