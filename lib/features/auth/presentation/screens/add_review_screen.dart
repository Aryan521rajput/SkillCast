// lib/features/reviews/presentation/add_review_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reviews/data/review_bloc.dart';
import '../../../reviews/data/review_event.dart';

class AddReviewScreen extends StatefulWidget {
  final String courseId;
  final String userId;
  final String userName;

  const AddReviewScreen({
    super.key,
    required this.courseId,
    required this.userId,
    required this.userName,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen>
    with SingleTickerProviderStateMixin {
  double rating = 0.0;
  final TextEditingController commentController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    commentController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------
  void submitReview() {
    final comment = commentController.text.trim();

    if (rating == 0) {
      _showError("Please select a rating");
      return;
    }
    if (comment.isEmpty) {
      _showError("Please write a comment");
      return;
    }

    context.read<ReviewBloc>().add(
      SubmitReviewRequested(
        courseId: widget.courseId,
        userId: widget.userId,
        userName: widget.userName,
        rating: rating,
        comment: comment,
      ),
    );

    Navigator.pop(context);
  }

  void _showError(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0E14)
          : const Color(0xFFF4F6FB),

      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Write a Review",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                _buildReviewCard(isDark),
                const SizedBox(height: 26),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⭐ Review Card (Stars + Comment)
  // ---------------------------------------------------------------------------
  Widget _buildReviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D26) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Rating",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 16),

          /// Interactive Stars
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = (i + 1) <= rating;

                return GestureDetector(
                  onTap: () => setState(() => rating = (i + 1).toDouble()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      filled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                      size: filled ? 34 : 28,
                      color: filled
                          ? const Color(0xFFFCC200)
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            "Comment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 10),

          // COMMENT BOX FIXED FOR DARK MODE
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1218) : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: CupertinoTextField(
              controller: commentController,
              maxLines: 5,
              padding: const EdgeInsets.all(14),

              // FIXED: readable text in both modes
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),

              cursorColor: isDark ? Colors.white : Colors.black,

              placeholder: "Write something about this course...",
              placeholderStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),

              decoration: const BoxDecoration(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildSubmitButton() {
    return CupertinoButton.filled(
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(vertical: 14),
      onPressed: submitReview,
      child: const Text(
        "Submit Review",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    );
  }
}
