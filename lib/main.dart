// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/navigation/app_router.dart';
import 'core/theme_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/main_tab_screen.dart';
import 'firebase_options.dart';

// BLoC
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/course_bloc.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/course_event.dart';
import 'bloc/profile_event.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/repositories/course_repository.dart';
import 'features/auth/data/repositories/user_repository.dart';

import 'features/live/data/live_class_repository.dart';
import 'features/live/domain/live_class_bloc.dart';

import 'features/reviews/data/review_bloc.dart';
import 'features/reviews/data/review_repository.dart';

import 'features/lessons/data/lesson_bloc.dart';
import 'features/lessons/data/lesson_repository.dart';

/// -----------------------------------------------------------
/// APP THEME (kept similar to your last file)
/// -----------------------------------------------------------
class AppTheme {
  static const Color primaryBlue = Color(0xFF5B7FFF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: "Inter",
    scaffoldBackgroundColor: const Color(0xFFF4F6FB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Color(0xFFF4F6FB),
      barBackgroundColor: CupertinoColors.systemGrey6,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF4F6FB),
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: "Roboto",
    scaffoldBackgroundColor: const Color(0xFF0B0E14),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Color(0xFF0B0E14),
      barBackgroundColor: Color(0xFF0B0E14),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B0E14),
      elevation: 0,
    ),
  );
}

/// -----------------------------------------------------------
/// MAIN
/// -----------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SkillCastApp());
}

class SkillCastApp extends StatelessWidget {
  const SkillCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, themeMode, _) {
        return MultiBlocProvider(
          providers: [
            /// AUTH
            BlocProvider(
              create: (_) =>
                  AuthBloc(authRepository: AuthRepository())
                    ..add(AuthCheckRequested()),
            ),

            /// COURSES
            BlocProvider(
              create: (context) => CourseBloc(
                repo: CourseRepository(),
                authBloc: context.read<AuthBloc>(),
              )..add(LoadCoursesRequested()),
            ),

            /// PROFILE
            BlocProvider(create: (_) => ProfileBloc(repo: UserRepository())),

            /// LIVE CLASSES
            BlocProvider(
              create: (_) => LiveClassBloc(repo: LiveClassRepository()),
            ),

            /// REVIEWS
            BlocProvider(create: (_) => ReviewBloc(repo: ReviewRepository())),

            /// LESSONS
            BlocProvider(create: (_) => LessonBloc(repo: LessonRepository())),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,

            // THEMES
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            supportedLocales: const [Locale('en')],
            localizationsDelegates: const [
              DefaultWidgetsLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],

            // Use AuthGate as the home so we can immediately decide which screen to show
            home: const AuthGate(),

            // Keep onGenerateRoute for named routes you use elsewhere
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );
      },
    );
  }
}

/// -----------------------------------------------------------
/// AUTH GATE — shows loader while auth check runs, returns
/// LoginScreen when not authenticated, MainTabScreen when authenticated.
/// This prevents the login screen flash and makes transitions immediate.
/// -----------------------------------------------------------
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, dynamic>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading || prev.user != curr.user,
      builder: (context, state) {
        // state is AuthState — but we typed dynamic to avoid import issues here.
        final isLoading = state.isLoading ?? false;
        final user = state.user;

        if (isLoading) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (user != null) {
          // user already authenticated — go to main tab
          return MainTabScreen(initialIndex: 0);
        }

        // not authenticated — show login
        return const LoginScreen();
      },
    );
  }
}
