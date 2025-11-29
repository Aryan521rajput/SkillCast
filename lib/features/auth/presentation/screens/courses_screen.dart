import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/course_bloc.dart';
import '../../../../bloc/course_event.dart';
import '../../../../bloc/course_state.dart';

import '../../../reviews/data/review_bloc.dart';
import '../../../reviews/data/review_repository.dart';
import '../../../reviews/data/review_event.dart';

import 'course_detail_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Load courses once
    context.read<CourseBloc>().add(LoadCoursesRequested());

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Courses",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

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

          final courses = state.courses;

          if (courses.isEmpty) {
            return const Center(
              child: Text(
                "No Courses Available",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),

            itemBuilder: (context, index) {
              final course = courses[index];
              return _CourseTile(course: course);
            },
          );
        },
      ),
    );
  }
}

/// ----------------------------------------------------------------------
/// FIXED: NO HOOKS. Each tile is a StatefulWidget with its own animation.
/// ----------------------------------------------------------------------
class _CourseTile extends StatefulWidget {
  final dynamic course;

  const _CourseTile({required this.course});

  @override
  State<_CourseTile> createState() => _CourseTileState();
}

class _CourseTileState extends State<_CourseTile> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),

      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) => setState(() => pressed = false),
        onTapCancel: () => setState(() => pressed = false),

        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => BlocProvider(
                create: (_) =>
                    ReviewBloc(repo: ReviewRepository())
                      ..add(LoadReviewsRequested(course.id)),
                child: CourseDetailScreen(courseId: course.id),
              ),
            ),
          );
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),

          transform: (hovered || pressed)
              ? Matrix4.diagonal3Values(1.02, 1.02, 1)
              : Matrix4.identity(),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),

            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1E),
                ),
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION
              Text(
                course.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: CupertinoColors.systemGrey,
                ),
              ),

              const SizedBox(height: 12),

              /// INSTRUCTOR
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.person_fill,
                    size: 18,
                    color: Color(0xFF5B7FFF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    course.instructorName ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B7FFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
