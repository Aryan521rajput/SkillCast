// lib/features/courses/presentation/screens/lesson_list_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../lessons/data/lesson_bloc.dart';
import '../../../lessons/data/lesson_event.dart';
import '../../../lessons/data/lesson_state.dart';
import 'lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String courseId;

  const LessonListScreen({required this.courseId, super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  @override
  void initState() {
    super.initState();

    // Load lessons only once
    context.read<LessonBloc>().add(LoadLessonsRequested(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Lessons")),
      child: SafeArea(
        child: BlocBuilder<LessonBloc, LessonState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            if (state.lessons.isEmpty) {
              return const Center(child: Text("No lessons available"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.lessons.length,
              itemBuilder: (context, index) {
                final lesson = state.lessons[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => LessonDetailScreen(lesson: lesson),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
