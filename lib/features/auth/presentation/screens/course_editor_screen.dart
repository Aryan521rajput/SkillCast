// lib/features/auth/presentation/screens/course_editor_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme_controller.dart';

class CourseEditorScreen extends StatefulWidget {
  final String? courseId;

  const CourseEditorScreen({super.key, this.courseId});

  @override
  State<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<CourseEditorScreen> {
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _instructorCtl = TextEditingController();
  final _videoCtl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _embedding = false;

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      _loadCourse();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadCourse() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.courseId)
          .get();

      final d = snap.data();
      if (d != null) {
        _titleCtl.text = d["title"] ?? "";
        _descCtl.text = d["description"] ?? "";
        _instructorCtl.text = d["instructorName"] ?? "";
        _videoCtl.text = d["videoUrl"] ?? "";
      }
    } catch (_) {
      // ignore load error here; UI will show empty fields
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    _instructorCtl.dispose();
    _videoCtl.dispose();
    super.dispose();
  }

  // Extract ID using a simple regex (keeps same approach)
  String? _extractYoutubeId(String url) {
    final reg = RegExp(r'([A-Za-z0-9_-]{11})');
    return reg.firstMatch(url)?.group(1);
  }

  String _makeEmbed(String id) {
    return "https://www.youtube.com/embed/$id?rel=0&modestbranding=1&playsinline=1";
  }

  // EMBED URL — now safe: shows confirm dialog, sets _embedding while updating firestore, awaits completion
  Future<void> _embedUrl() async {
    final raw = _videoCtl.text.trim();
    if (raw.isEmpty) {
      _snack("No video URL entered");
      return;
    }

    final id = _extractYoutubeId(raw);
    if (id == null) {
      _snack("Invalid YouTube URL");
      return;
    }

    final embed = _makeEmbed(id);

    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Convert to Embed"),
        content: Text("Replace with:\n$embed"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Replace"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // update local text immediately for quick feedback
    setState(() {
      _videoCtl.text = embed;
    });

    // If editing an existing course, persist the embed URL to Firestore.
    if (widget.courseId != null) {
      setState(() => _embedding = true);
      try {
        await FirebaseFirestore.instance
            .collection("courses")
            .doc(widget.courseId)
            .update({"videoUrl": embed});
        _snack("Embed URL updated");
      } catch (e) {
        _snack("Failed to update embed: $e");
      } finally {
        if (mounted) setState(() => _embedding = false);
      }
    } else {
      // For a new course: just keep the embed url in the field (no DB update)
      _snack("Embed URL prepared");
    }
  }

  Future<void> _save() async {
    final data = {
      "title": _titleCtl.text.trim(),
      "description": _descCtl.text.trim(),
      "instructorName": _instructorCtl.text.trim(),
      "videoUrl": _videoCtl.text.trim(),
      "published": true,
      "createdAt": FieldValue.serverTimestamp(),
    };

    final title = data["title"]?.toString() ?? "";
    final desc = data["description"]?.toString() ?? "";

    if (title.isEmpty || desc.isEmpty) {
      _snack("Title and Description required");
      return;
    }

    setState(() => _saving = true);

    try {
      if (widget.courseId == null) {
        await FirebaseFirestore.instance.collection("courses").add(data);
        // show success then pop
        await _showSavedDialog("Course created");
      } else {
        await FirebaseFirestore.instance
            .collection("courses")
            .doc(widget.courseId)
            .update(data);
        await _showSavedDialog("Course updated");
      }
      // After showing dialog we return to previous screen
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack("Error: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showSavedDialog(String msg) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(msg),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text("Your changes were saved successfully."),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("OK"),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Input box — keep the same visuals, but adapt text color to brightness so text is always visible
  Widget _inputBox({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: bgColor,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16, color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark
        ? true
        : false;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF6F6FA),
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.courseId == null ? "New Course" : "Edit Course"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            ThemeController.instance.mode.value == ThemeMode.dark
                ? CupertinoIcons.sun_max_fill
                : CupertinoIcons.moon_fill,
          ),
          onPressed: () => ThemeController.instance.toggleTheme(),
        ),
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: _loading
              ? const Center(child: CupertinoActivityIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  children: [
                    _inputBox(label: "Course Title", controller: _titleCtl),
                    const SizedBox(height: 16),
                    _inputBox(
                      label: "Description",
                      controller: _descCtl,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _inputBox(
                      label: "Instructor Name",
                      controller: _instructorCtl,
                    ),
                    const SizedBox(height: 16),
                    _inputBox(label: "Video URL", controller: _videoCtl),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton.filled(
                            borderRadius: BorderRadius.circular(14),
                            onPressed: _saving ? null : _save,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.98,
                                        end: 1.0,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                              child: _saving
                                  ? const SizedBox(
                                      key: ValueKey('saving'),
                                      width: 20,
                                      height: 20,
                                      child: CupertinoActivityIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Save",
                                      key: ValueKey('save'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CupertinoButton(
                          color: CupertinoColors.activeOrange,
                          borderRadius: BorderRadius.circular(14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          onPressed: _embedding ? null : _embedUrl,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: _embedding
                                ? const SizedBox(
                                    key: ValueKey('embedding'),
                                    width: 18,
                                    height: 18,
                                    child: CupertinoActivityIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Embed URL",
                                    key: ValueKey('embed'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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
