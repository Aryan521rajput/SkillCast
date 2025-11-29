// my_courses_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../courses/domain/course_model.dart';

import '../../../reviews/data/review_bloc.dart';
import '../../../reviews/data/review_repository.dart';
import '../../../reviews/data/review_event.dart';

import '../../data/repositories/course_repository.dart';
import '../../presentation/screens/course_detail_screen.dart';

class MyCoursesScreen extends StatelessWidget {
  final String uid;

  const MyCoursesScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CourseRepository();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "My Courses",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: StreamBuilder<List<String>>(
          stream: repo.getUserEnrolledCourseIds(uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final ids = snapshot.data!;
            if (ids.isEmpty) {
              return const SizedBox.expand(
                child: Center(
                  child: Text(
                    "You have not enrolled in any courses yet.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              itemCount: ids.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final courseId = ids[index];

                return FutureBuilder<CourseModel?>(
                  future: repo.getCourse(courseId),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const CupertinoActivityIndicator();
                    }

                    final course = snap.data!;

                    return _AnimatedCourseTile(
                      course: course,
                      onUnEnroll: () async {
                        await repo.unEnrollUser(course.id, uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Course removed from My Courses"),
                          ),
                        );
                      },
                      onOpen: () {
                        // ⭐ APPLY SAME ANIMATION AS CoursesTab
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) => BlocProvider(
                              create: (_) =>
                                  ReviewBloc(repo: ReviewRepository())
                                    ..add(LoadReviewsRequested(course.id)),
                              child: CourseDetailScreen(courseId: course.id),
                            ),
                            transitionsBuilder:
                                (_, animation, secondaryAnim, child) {
                                  final fade = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  );
                                  final scale = Tween<double>(
                                    begin: 0.98,
                                    end: 1.0,
                                  ).animate(fade);

                                  return FadeTransition(
                                    opacity: fade,
                                    child: ScaleTransition(
                                      scale: scale,
                                      child: child,
                                    ),
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 260,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 220,
                            ),
                            opaque: true,
                            maintainState: true,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// ANIMATED TILE — unchanged
class _AnimatedCourseTile extends StatefulWidget {
  final CourseModel course;
  final VoidCallback onOpen;
  final VoidCallback onUnEnroll;

  const _AnimatedCourseTile({
    required this.course,
    required this.onOpen,
    required this.onUnEnroll,
    super.key,
  });

  @override
  State<_AnimatedCourseTile> createState() => _AnimatedCourseTileState();
}

class _AnimatedCourseTileState extends State<_AnimatedCourseTile> {
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
        onTap: widget.onOpen,
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
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(40),
                  onPressed: widget.onUnEnroll,
                  child: const Text(
                    "Un-Enroll",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
