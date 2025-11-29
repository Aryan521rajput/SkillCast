// lib/features/reviews/presentation/review_list_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reviews/data/review_bloc.dart';
import '../../../reviews/data/review_event.dart';
import '../../../reviews/data/review_state.dart';
import '../../../reviews/domain/review_model.dart';

class ReviewListWidget extends StatelessWidget {
  final String courseId;
  final String currentUserId;
  final bool canWriteReviews; // <-- NEW: Passed from CourseDetailScreen

  const ReviewListWidget({
    super.key,
    required this.courseId,
    required this.currentUserId,
    required this.canWriteReviews, // <-- required
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (state.reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "No reviews yet",
              style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
            ),
          );
        }

        return Column(
          children: List.generate(state.reviews.length, (i) {
            final review = state.reviews[i];
            final isOwner = review.userId == currentUserId;

            return _AnimatedReviewTile(
              delay: i * 120,
              child: _ReviewCard(
                review: review,
                isOwner: isOwner,
                canWriteReviews: canWriteReviews, // <-- applied
                courseId: courseId,
                currentUserId: currentUserId,
              ),
            );
          }),
        );
      },
    );
  }
}

/// ==========================================================================
/// ✨ ANIMATED TILE
/// ==========================================================================
class _AnimatedReviewTile extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedReviewTile({required this.child, required this.delay});

  @override
  State<_AnimatedReviewTile> createState() => _AnimatedReviewTileState();
}

class _AnimatedReviewTileState extends State<_AnimatedReviewTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// ==========================================================================
/// ⭐ Review Card
/// ==========================================================================
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isOwner;
  final bool canWriteReviews; // <-- NEW: permission
  final String courseId;
  final String currentUserId;

  const _ReviewCard({
    required this.review,
    required this.isOwner,
    required this.canWriteReviews, // <-- injected
    required this.courseId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// USERNAME + ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              /// Only allow edit/delete if:
              /// 1) The review belongs to the current user
              /// 2) The user is enrolled (canWriteReviews == true)
              if (isOwner && canWriteReviews)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEdit(context),
                      child: const Icon(
                        CupertinoIcons.pencil_circle,
                        color: CupertinoColors.activeBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: const Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors.systemRed,
                        size: 22,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 8),

          _StarDisplay(rating: review.rating),
          const SizedBox(height: 10),

          Text(
            review.comment,
            style: const TextStyle(fontSize: 15, height: 1.35),
          ),
        ],
      ),
    );
  }

  /// ========================================================================
  /// EDIT
  /// ========================================================================
  void _showEdit(BuildContext context) {
    if (!canWriteReviews) return; // <-- BLOCK if not enrolled

    final controller = TextEditingController(text: review.comment);
    double rating = review.rating;

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: const Text("Edit Review"),
              content: Column(
                children: [
                  const SizedBox(height: 12),
                  _EditableStars(
                    rating: rating,
                    onChanged: (r) => setState(() => rating = r),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(controller: controller, maxLines: 4),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text("Save"),
                  onPressed: () {
                    context.read<ReviewBloc>().add(
                      EditReviewRequested(
                        reviewId: review.id,
                        courseId: review.courseId,
                        rating: rating,
                        comment: controller.text.trim(),
                      ),
                    );

                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ========================================================================
  /// DELETE
  /// ========================================================================
  void _confirmDelete(BuildContext context) {
    if (!canWriteReviews) return; // <-- BLOCK if not enrolled

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Delete Review"),
          content: const Text("Are you sure you want to delete this review?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("Delete"),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ReviewBloc>().add(
                  DeleteReviewRequested(
                    reviewId: review.id,
                    courseId: review.courseId,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// ==========================================================================
/// ⭐ STAR DISPLAY
/// ==========================================================================
class _StarDisplay extends StatelessWidget {
  final double rating;

  const _StarDisplay({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;

    return Row(
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(
            CupertinoIcons.star_fill,
            size: 18,
            color: Color(0xFFFCC200),
          );
        }
        if (i == full && half) {
          return const Icon(
            CupertinoIcons.star_lefthalf_fill,
            size: 18,
            color: Color(0xFFFCC200),
          );
        }
        return const Icon(
          CupertinoIcons.star,
          size: 18,
          color: CupertinoColors.systemGrey,
        );
      }),
    );
  }
}

/// ==========================================================================
/// ⭐ STAR INPUT FOR EDITING
/// ==========================================================================
class _EditableStars extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _EditableStars({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = rating >= (i + 1);

        return GestureDetector(
          onTap: () => onChanged((i + 1).toDouble()),
          child: Icon(
            filled ? CupertinoIcons.star_fill : CupertinoIcons.star,
            size: 27,
            color: filled
                ? const Color(0xFFFCC200)
                : CupertinoColors.systemGrey,
          ),
        );
      }),
    );
  }
}
