import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _nidaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  static const Color _primaryColor = Color(0xFF1A237E);
  static const Color _backgroundColor = Color(0xFFF0F2FA);

  @override
  void dispose() {
    _fullNameController.dispose();
    _nidaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

 void _onCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await AuthService.register(
        fullName:        _fullNameController.text.trim(),
        nidaNumber:      _nidaController.text.trim(),
        phoneNumber:     _phoneController.text.trim(),
        email:           _emailController.text.trim(),
        password:        _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        // Show success and go to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to login screen
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Full Name ──
                _buildLabel('Full Name'),
                _buildTextField(
                  controller: _fullNameController,
                  hint: 'Jonathan Mkumbo',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter your full name' : null,
                ),

                const SizedBox(height: 20),

                // ── NIDA Number ──
                _buildLabel('NIDA Number'),
                _buildTextField(
                  controller: _nidaController,
                  hint: 'Enter your 20-digit NIDA number',
                  icon: Icons.fingerprint,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(20),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your NIDA number';
                    if (val.length != 20) return 'NIDA number must be 20 digits';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Phone Number ──
                _buildLabel('Phone Number'),
                _buildTextField(
                  controller: _phoneController,
                  hint: '+255 XXX XXX XXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter your phone number' : null,
                ),

                const SizedBox(height: 20),

                // ── Email Address ──
                _buildLabel('Email Address'),
                _buildTextField(
                  controller: _emailController,
                  hint: 'email@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your email';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Password ──
                _buildLabel('Password'),
                _buildPasswordField(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter a password';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Confirm Password ──
                _buildLabel('Confirm Password'),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hint: '••••••••',
                  icon: Icons.lock_reset_outlined,
                  obscure: _obscureConfirmPassword,
                  onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Confirm your password';
                    if (val != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ── Create Account Button ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onCreateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Login Link ──
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF777777)),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A237E),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── LABEL WIDGET ──
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  // ── TEXT FIELD WIDGET ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFAAAAAA), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A237E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  // ── PASSWORD FIELD WIDGET ──
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFAAAAAA), size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFFAAAAAA),
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A237E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}