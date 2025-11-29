// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/auth_event.dart';
import '../../../../bloc/auth_state.dart';

class RegisterScreen extends HookWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pageBg = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final inputBg = isDark ? const Color(0xFF111217) : Colors.white;
    final inputTextColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.black54;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // When registration succeeds -> show message -> go to login page
        if (!state.isLoading &&
            state.error == null &&
            state.userId == null &&
            state.user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created! Please login."),
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        backgroundColor: pageBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "Create Account ✨",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 30),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        if (!isDark)
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
                          controller: nameController,
                          label: "Full Name",
                          inputBg: inputBg,
                          inputTextColor: inputTextColor,
                          labelColor: labelColor,
                        ),
                        const SizedBox(height: 16),

                        _inputField(
                          controller: emailController,
                          label: "Email",
                          inputBg: inputBg,
                          inputTextColor: inputTextColor,
                          labelColor: labelColor,
                        ),
                        const SizedBox(height: 16),

                        _inputField(
                          controller: passwordController,
                          label: "Password",
                          obscure: true,
                          inputBg: inputBg,
                          inputTextColor: inputTextColor,
                          labelColor: labelColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B7FFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final email = emailController.text.trim();
                      final pass = passwordController.text.trim();

                      if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all fields"),
                          ),
                        );
                        return;
                      }

                      context.read<AuthBloc>().add(
                        AuthRegisterRequested(email, pass, name),
                      );
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required Color inputBg,
    required Color inputTextColor,
    required Color labelColor,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        fontSize: 16,
        color: inputTextColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
    );
  }
}
