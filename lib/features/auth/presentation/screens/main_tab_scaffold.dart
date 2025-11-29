import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/course_bloc.dart';

import 'home_screen.dart';
import 'courses_screen.dart';
import 'my_courses_screen.dart';
import 'profile_screen.dart';

class MainTabScaffold extends StatelessWidget {
  const MainTabScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().state.userId ?? "";

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: const Color(0xFF5B7FFF),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_solid),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.play_rectangle_fill),
            label: "My Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: "Profile",
          ),
        ],
      ),

      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (_) => HomeScreen());

          case 1:
            return CupertinoTabView(
              builder: (tabContext) => BlocProvider.value(
                value: context.read<CourseBloc>(),
                child: const CoursesScreen(),
              ),
            );

          case 2:
            return CupertinoTabView(
              builder: (tabContext) => BlocProvider.value(
                value: context.read<CourseBloc>(),
                child: MyCoursesScreen(uid: uid),
              ),
            );

          case 3:
            return CupertinoTabView(builder: (_) => ProfileScreen(uid: uid));

          default:
            return CupertinoTabView(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
