// lib/features/courses/presentation/screens/lesson_detail_screen.dart
import 'package:flutter/cupertino.dart';
import '../../../lessons/domain/lesson_model.dart';
import 'lesson_video_screen.dart';

class LessonDetailScreen extends StatelessWidget {
  final LessonModel lesson;

  const LessonDetailScreen({required this.lesson, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(lesson.title)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text(lesson.content, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 20),

              if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty)
                CupertinoButton.filled(
                  child: const Text("Watch Video"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) =>
                            LessonVideoScreen(videoUrl: lesson.videoUrl!),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
