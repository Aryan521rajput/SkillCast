// lib/features/auth/presentation/screens/auth_wrapper.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillcast/bloc/auth_bloc.dart';
import 'package:skillcast/bloc/auth_state.dart';

import 'admin_dashboard.dart';
import 'main_tab_scaffold.dart';
import 'login_screen.dart'; // ← make sure this import matches your actual path

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // while we're actively loading/initializing, show a splash/progress
        if (state.isLoading) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        // no user signed in -> show login screen
        if (state.userId == null) {
          return const LoginScreen();
        }

        // we have a user; if profile present and admin show admin UI
        final user = state.user;
        if (user != null && user.role == 'Admin') {
          return const AdminDashboard();
        }

        // regular logged-in user
        return const MainTabScaffold();
      },
    );
  }
}
