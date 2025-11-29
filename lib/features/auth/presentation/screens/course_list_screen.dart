import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../bloc/course_bloc.dart';
import '../../../../bloc/course_state.dart';
import '../../../../bloc/course_event.dart';
import 'course_card.dart';
// import '../../../courses/domain/course_model.dart';

class CourseListScreen extends HookWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger course loading on screen build
    useEffect(() {
      context.read<CourseBloc>().add(LoadCoursesRequested());
      return null;
    }, []);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Courses")),
      child: SafeArea(
        child: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Text(
                  "Error: ${state.error}",
                  style: const TextStyle(color: CupertinoColors.systemRed),
                ),
              );
            }

            if (state.courses.isEmpty) {
              return const Center(child: Text("No courses available."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                return CourseCard(course: course);
              },
            );
          },
        ),
      ),
    );
  }
}
