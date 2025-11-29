import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/auth_state.dart';

import '../screens/home_screen.dart';
import '../screens/courses_tab.dart';
import '../screens/profile_screen.dart';
import '../screens/my_courses_screen.dart';

import '../screens/admin_dashboard.dart';
import '../screens/admin_profile_screen.dart';

class MainTabScreen extends StatelessWidget {
  final int initialIndex;
  const MainTabScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth.user;

    if (user == null) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final bool isAdmin = user.role.toLowerCase() == "admin";

    // ⭐ FIX: Controller to correctly switch tabs
    final controller = CupertinoTabController(initialIndex: initialIndex);

    return CupertinoTabScaffold(
      controller: controller, // ← FIX APPLIED HERE

      tabBar: CupertinoTabBar(
        items: isAdmin
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.rectangle_grid_2x2),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_circle),
                  label: "Profile",
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.book),
                  label: "Courses",
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.book_fill),
                  label: "My Courses",
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_circle),
                  label: "Profile",
                ),
              ],
      ),

      tabBuilder: (context, index) {
        if (isAdmin) {
          return CupertinoTabView(
            builder: (_) {
              if (index == 0) return const AdminDashboard();
              return AdminProfileScreen(uid: user.uid);
            },
          );
        }

        return CupertinoTabView(
          builder: (_) {
            if (index == 0) return const HomeScreen();
            if (index == 1) return const CoursesTab();
            if (index == 2) return MyCoursesScreen(uid: user.uid);
            return ProfileScreen(uid: user.uid);
          },
        );
      },
    );
  }
}
