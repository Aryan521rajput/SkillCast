import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../bloc/course_bloc.dart';
import '../../../../bloc/course_event.dart';
import '../../../courses/domain/course_model.dart';
import '../../../../bloc/auth_bloc.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final instructorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AuthBloc>().state.user;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Create Course"),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Course Title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CupertinoTextField(controller: titleController),

            const SizedBox(height: 20),

            const Text(
              "Course Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CupertinoTextField(controller: descController, maxLines: 4),

            const SizedBox(height: 20),

            const Text(
              "Instructor Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CupertinoTextField(
              controller: instructorController,
              placeholder: "Example: Aryan, John Doe",
            ),

            const SizedBox(height: 30),

            CupertinoButton.filled(
              child: const Text("Create"),
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                final instructorName = instructorController.text.trim();

                if (title.isEmpty || desc.isEmpty || instructorName.isEmpty) {
                  return;
                }

                final course = CourseModel(
                  id: const Uuid().v4(),
                  title: title,
                  description: desc,
                  instructorName: instructorName,
                  createdAt: DateTime.now(),
                );

                context.read<CourseBloc>().add(CreateCourseRequested(course));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
