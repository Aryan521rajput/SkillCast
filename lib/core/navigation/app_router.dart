// lib/core/navigation/app_router.dart
import 'package:flutter/cupertino.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/main_tab_screen.dart';
import '../../features/auth/presentation/screens/search_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return CupertinoPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return CupertinoPageRoute(builder: (_) => const RegisterScreen());

      case '/forgot':
        return CupertinoPageRoute(builder: (_) => const ForgotPasswordScreen());

      case '/home':
        return CupertinoPageRoute(builder: (_) => const HomeScreen());

      case '/main':
        // allow passing an initial tab index via arguments (int)
        int initialIndex = 0;
        if (settings.arguments is int) {
          initialIndex = settings.arguments as int;
        }
        return CupertinoPageRoute(
          builder: (_) => MainTabScreen(initialIndex: initialIndex),
        );

      case '/search':
        return CupertinoPageRoute(builder: (_) => const SearchScreen());

      default:
        return CupertinoPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
