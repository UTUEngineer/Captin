import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'captain_main_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  // حالة الشاشة (تسجيل دخول أم إنشاء حساب)
  bool isLoginMode = true;
  bool isLoading = false;
  bool isPasswordVisible = false;

  // الحقول والـ Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _clubNameController = TextEditingController();

  final _supabaseService = SupabaseService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _clubNameController.dispose();
    super.dispose();
  }

  // ميثود تنفيذ تسجيل الدخول أو إنشاء الحساب
  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isLoginMode) {
        // 1. تسجيل الدخول
        await _supabaseService.signInCoach(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // 2. إنشاء حساب كابتن جديد
        await _supabaseService.signUpCoach(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLoginMode ? "أهلاً بك مجدداً كابتن!" : "تم إنشاء الحساب بنجاح!"),
            backgroundColor: Colors.green,
          ),
        );

        // الانتقال للداشبورد مباشرة
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const CaptainMainDashboard(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate Background
      body: Stack(
        children: [
          // خلفية إضاءة زرقاء خفيفة لتأثير الـ Neon Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // A. شعار التطبيق والعنوان (App Logo & Title)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 48,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "CAPTAIN TACTICAL SUITE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLoginMode ? "سجّل دخولك للوصول إلى تحليلاتك والسبورة 3D" : "أنشئ حسابك وابدأ تحليل المباريات بالذكاء الاصطناعي",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // B. بطاقة الإدخال الزجاجية (Dark Glass Auth Card)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // تبديل بين Login / Signup (Segmented Control)
                          _buildModeSwitcher(),

                          const SizedBox(height: 24),

                          // حقل الاسم الكامل (في حالة إنشاء حساب جديد فقط)
                          if (!isLoginMode) ...[
                            _buildTextField(
                              controller: _fullNameController,
                              label: "الاسم الكامل (الكابتن)",
                              icon: Icons.person_outline,
                              validator: (v) => (v == null || v.isEmpty) ? "يرجى إدخال الاسم" : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // حقل البريد الإلكتروني
                          _buildTextField(
                            controller: _emailController,
                            label: "البريد الإلكتروني",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty || !v.contains('@')) {
                                return "يرجى إدخال بريد إلكتروني صحيح";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // حقل كلمة المرور
                          _buildTextField(
                            controller: _passwordController,
                            label: "كلمة المرور",
                            icon: Icons.lock_outline,
                            obscureText: !isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white38,
                              ),
                              onPressed: () {
                                setState(() => isPasswordVisible = !isPasswordVisible);
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return "كلمة المرور يجب أن لا تقل عن 6 خانات";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // زر إرسال الطلب (Submit Button)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0EA5E9), // Sky Blue Accent
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            onPressed: isLoading ? null : _submitAuth,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    isLoginMode ? "تسجيل الدخول" : "إنشاء حساب الكابتن",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                          ),

                          const SizedBox(height: 12),

                          // زر الدخول السريع كـ كابتن (تخطي التسجيل)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const CaptainMainDashboard(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bolt, color: Color(0xFF10B981)),
                            label: const Text(
                              "⚡ دخول سريع ومجاني كـ كابتن (تخطي التسجيل)",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // كود أداة التبديل السلسة بين Login / Signup
  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isLoginMode = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isLoginMode ? const Color(0xFF1E293B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isLoginMode ? Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)) : null,
                ),
                child: Text(
                  "تسجيل الدخول",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLoginMode ? Colors.white : Colors.white54,
                    fontWeight: isLoginMode ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isLoginMode = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isLoginMode ? const Color(0xFF1E293B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: !isLoginMode ? Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)) : null,
                ),
                child: Text(
                  "حساب جديد",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !isLoginMode ? Colors.white : Colors.white54,
                    fontWeight: !isLoginMode ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // كود حقل الإدخال الموحد (TextField Builder)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF38BDF8), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0F172A).withValues(alpha: 0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF38BDF8)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: validator,
    );
  }
}
