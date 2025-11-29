import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/auth_event.dart';
import '../../../../bloc/auth_state.dart';

class ForgotPasswordScreen extends HookWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final isSending = useState(false);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Reset Password"),
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          isSending.value = state.isLoading;

          if (!state.isLoading && state.error == null) {
            showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: const Text("Email Sent"),
                content: const Text(
                    "Check your inbox for password reset instructions."),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }

          if (state.error != null) {
            showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: const Text("Error"),
                content: Text(state.error!),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: emailController,
                  placeholder: "Enter your email",
                  padding: const EdgeInsets.all(16),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  child: isSending.value
                      ? const CupertinoActivityIndicator()
                      : const Text("Send Reset Link"),
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          AuthPasswordResetRequested(
                            emailController.text.trim(),
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
