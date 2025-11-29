// lib/features/auth/presentation/screens/admin/admin_dashboard.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme_controller.dart';
import '../../../courses/domain/course_model.dart';
import '../../data/repositories/course_repository.dart';
import 'course_editor_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final repo = CourseRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            ThemeController.instance.mode.value == ThemeMode.dark
                ? CupertinoIcons.sun_max_fill
                : CupertinoIcons.moon_fill,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => ThemeController.instance.toggleTheme(),
        ),
      ),

      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // ➕ Add Course Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Text(
                  "➕ Add New Course",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const CourseEditorScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: StreamBuilder<List<CourseModel>>(
                stream: repo.getAllCourses(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final courses = snapshot.data!;
                  if (courses.isEmpty) {
                    return const Center(child: Text("No courses yet"));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final c = courses[index];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : CupertinoColors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Row + Buttons
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    c.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                // ✏ Edit Button
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            CourseEditorScreen(courseId: c.id),
                                      ),
                                    );

                                    // After return, show popup
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Changes saved!"),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    CupertinoIcons.pencil_circle_fill,
                                    size: 30,
                                    color: CupertinoColors.activeBlue,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // 🗑 Delete Button
                                GestureDetector(
                                  onTap: () => _confirmDelete(context, c),
                                  child: const Icon(
                                    CupertinoIcons.delete_solid,
                                    size: 30,
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text(
                              c.description,
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
                                Expanded(
                                  child: Text(
                                    c.instructorName ?? "Unknown",
                                    style: const TextStyle(
                                      color: Color(0xFF5B7FFF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // CONFIRM DELETE DIALOG
  // ----------------------------------------------------------------------
  void _confirmDelete(BuildContext context, CourseModel course) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Delete Course"),
        content: Text("Are you sure you want to delete '${course.title}'?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.pop(ctx);

              await repo.deleteCourse(course.id);

              // Popup confirming deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Course deleted"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
