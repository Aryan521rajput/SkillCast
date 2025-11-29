// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/auth_event.dart';
import '../../../../bloc/auth_state.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final animController = useAnimationController(
      duration: const Duration(milliseconds: 700),
    )..forward();

    final fade = CurvedAnimation(
      parent: animController,
      curve: Curves.easeInOut,
    );

    final slide = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: animController, curve: Curves.easeOutCubic),
        );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputTextColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    final pageBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.user == null && curr.user != null,
          listener: (context, state) {
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),

        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.error != curr.error && curr.error != null,
          listener: (context, state) {
            final msg = state.error ?? 'Authentication error';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );

            context.read<AuthBloc>().add(AuthClearError());
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: pageBg,
        body: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Login to continue your learning",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _inputField(
                              context: context,
                              controller: emailController,
                              label: "Email",
                              icon: Icons.email_rounded,
                              inputTextColor: inputTextColor,
                              labelColor: labelColor,
                            ),
                            const SizedBox(height: 16),
                            _inputField(
                              context: context,
                              controller: passwordController,
                              label: "Password",
                              icon: Icons.lock_rounded,
                              obscure: true,
                              inputTextColor: inputTextColor,
                              labelColor: labelColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state.isLoading;

                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B7FFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      final email = emailController.text.trim();
                                      final pass = passwordController.text
                                          .trim();

                                      if (email.isEmpty || pass.isEmpty) {
                                        _showError(
                                          context,
                                          "Please enter email and password",
                                        );
                                        return;
                                      }

                                      context.read<AuthBloc>().add(
                                        AuthLoginRequested(email, pass),
                                      );
                                    },
                              child: isLoading
                                  ? const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: Color(0xFF5B7FFF),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FIXED INPUT FIELD — now receives proper BuildContext
  Widget _inputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color inputTextColor,
    required Color labelColor,
    bool obscure = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: inputTextColor,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF111217) : const Color(0xFFF0F2F7),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22),
        labelText: label,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: labelColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
