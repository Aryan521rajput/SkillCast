// lib/features/auth/presentation/screens/course_detail_screen.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../courses/domain/course_model.dart';
import '../../../auth/data/repositories/course_repository.dart';

import '../../../../bloc/auth_bloc.dart';
import '../../../../bloc/course_bloc.dart';
import '../../../../bloc/course_event.dart';

import 'add_review_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with WidgetsBindingObserver {
  final CourseRepository _repo = CourseRepository();
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  YoutubePlayerController? _ytController;
  bool _loading = true;
  CourseModel? _course;
  bool _mountedSafely = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mountedSafely = true;
    _loadCourse();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mountedSafely = false;
    _ytController?.removeListener(_ytListener);
    _ytController?.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    try {
      final course = await _repo.getCourse(widget.courseId);

      if (!_mountedSafely) return;

      if (course == null) {
        setState(() {
          _course = null;
          _loading = false;
        });
        return;
      }

      final id = YoutubePlayer.convertUrlToId(course.videoUrl ?? "");

      if (id != null) {
        // dispose previous controller if any
        _ytController?.removeListener(_ytListener);
        _ytController?.pause();
        _ytController?.dispose();

        _ytController = YoutubePlayerController(
          initialVideoId: id,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            disableDragSeek: false,
          ),
        )..addListener(_ytListener);
      }

      setState(() {
        _course = course;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _course = null;
        _loading = false;
      });
    }
  }

  void _ytListener() {
    // reserved for lightweight reactions if needed
  }

  Future<void> _openFullscreen(String videoId) async {
    if (videoId.isEmpty) return;
    _ytController?.pause();

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => _YoutubeFullScreenPage(videoId: videoId),
      ),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;

    if (_loading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_course == null) {
      return const CupertinoPageScaffold(
        child: Center(child: Text("Course not found")),
      );
    }

    final course = _course!;
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width;
    final playerHeight = (width * 9 / 16).clamp(220.0, 520.0);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          course.title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            // Title
            Text(
              course.title,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),

            // Instructor + date
            Row(
              children: [
                const Icon(CupertinoIcons.person, size: 18, color: Color(0xFF5B7FFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    course.instructorName ?? "Unknown",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  course.createdAt?.toLocal().toString().split(' ').first ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // PLAYER CARD
            Container(
              height: playerHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _ytController == null
                    ? _videoFallback(context, course)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          YoutubePlayer(
                            controller: _ytController!,
                            showVideoProgressIndicator: true,
                            onEnded: (meta) {},
                            bottomActions: [
                              CurrentPosition(),
                              ProgressBar(isExpanded: true),
                              RemainingDuration(),
                              GestureDetector(
                                onTap: () {
                                  final id = _ytController!.metadata.videoId;
                                  if (id.isNotEmpty) _openFullscreen(id);
                                },
                                child: const Icon(Icons.fullscreen, color: Colors.white, size: 22),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Text(
              course.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 22),

            // ENROLL SECTION
            _buildEnrollSection(course.id, auth.userId),
            const SizedBox(height: 24),

            // Reviews header — show Write only when enrolled
            StreamBuilder<bool>(
              stream: _repo.isUserEnrolled(course.id, auth.userId ?? ""),
              builder: (context, snapEnrolled) {
                final enrolled = snapEnrolled.data ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Reviews",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (enrolled)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("Write"),
                        onPressed: () {
                          // push AddReviewScreen (keeps animation simple)
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => AddReviewScreen(
                                courseId: course.id,
                                userId: auth.userId ?? "",
                                userName: auth.user?.name ?? "",
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // REVIEWS STREAM — always visible regardless of enrollment
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _fs
                  .collection('reviews')
                  .where('courseId', isEqualTo: course.id)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "No reviews yet",
                      style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
                    ),
                  );
                }

                final docs = snap.data!.docs;
                return Column(
                  children: docs.map((d) {
                    final data = d.data();
                    final review = ReviewViewModel.fromMap(d.id, data);
                    final isOwner = (auth.userId ?? "") == (data['userId'] ?? "");

                    // Show edit/delete only if owner AND currently enrolled.
                    return _ReviewTile(
                      review: review,
                      allowActionsStream: _repo.isUserEnrolled(course.id, auth.userId ?? ""),
                      isOwner: isOwner,
                      reviewDocId: d.id,
                      onDeleted: () {
                        // optional: show toast (handled below)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review deleted")),
                        );
                      },
                      onUpdated: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review updated")),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoFallback(BuildContext context, CourseModel course) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.play_circle, size: 56, color: Colors.white70),
            const SizedBox(height: 10),
            const Text('Video unavailable for inline playback',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open original'),
              onPressed: () async {
                final raw = _course?.videoUrl;
                if (raw == null || raw.isEmpty) return;
                final uri = Uri.tryParse(raw);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (_mountedSafely) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot open URL')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollSection(String courseId, String? userId) {
    if (userId == null) {
      return CupertinoButton.filled(
        child: const Text("Sign in to enroll"),
        onPressed: () => Navigator.pushNamed(context, "/login"),
      );
    }

    return StreamBuilder<bool>(
      stream: _repo.isUserEnrolled(courseId, userId),
      builder: (context, snap) {
        final enrolled = snap.data ?? false;

        if (enrolled) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Text(
              "You are enrolled ✓",
              style: TextStyle(fontSize: 16, color: CupertinoColors.activeGreen, fontWeight: FontWeight.w700),
            ),
          );
        }

        return CupertinoButton.filled(
          child: const Text("Enroll in Course"),
          onPressed: () {
            context.read<CourseBloc>().add(EnrollCourseRequested(courseId));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enrolled successfully!")));
          },
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Small local review view model (shim) to render review entries fetched
/// directly from Firestore.
/// ---------------------------------------------------------------------------
class ReviewViewModel {
  final String id;
  final String courseId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  ReviewViewModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewViewModel.fromMap(String id, Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    DateTime? created;
    if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else if (createdRaw is String) {
      created = DateTime.tryParse(createdRaw);
    }
    return ReviewViewModel(
      id: id,
      courseId: map['courseId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      comment: map['comment'] ?? '',
      createdAt: created,
    );
  }
}

/// ---------------------------------------------------------------------------
/// A review tile that shows edit/delete buttons only when `isOwner == true`
/// AND the `allowActionsStream` emits `true` (i.e., user is enrolled).
/// Edit/Delete perform direct Firestore updates so they work without needing
/// a ReviewBloc instance on the route.
/// ---------------------------------------------------------------------------
class _ReviewTile extends StatelessWidget {
  final ReviewViewModel review;
  final Stream<bool> allowActionsStream;
  final bool isOwner;
  final String reviewDocId;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const _ReviewTile({
    required this.review,
    required this.allowActionsStream,
    required this.isOwner,
    required this.reviewDocId,
    this.onDeleted,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (isOwner)
                StreamBuilder<bool>(
                  stream: allowActionsStream,
                  builder: (context, snap) {
                    final allow = snap.data ?? false;
                    if (!allow) return const SizedBox.shrink();
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showEditDialog(context),
                          child: const Icon(CupertinoIcons.pencil_circle, color: CupertinoColors.activeBlue, size: 22),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _confirmDelete(context),
                          child: const Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed, size: 22),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          _StarDisplay(rating: review.rating),
          const SizedBox(height: 10),
          Text(review.comment, style: const TextStyle(fontSize: 15, height: 1.35)),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: review.comment);
    double rating = review.rating;

    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (c, setState) {
            return CupertinoAlertDialog(
              title: const Text("Edit Review"),
              content: Column(
                children: [
                  const SizedBox(height: 12),
                  _EditableStars(rating: rating, onChanged: (r) => setState(() => rating = r)),
                  const SizedBox(height: 12),
                  CupertinoTextField(controller: controller, maxLines: 4),
                ],
              ),
              actions: [
                CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.pop(dialogContext)),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text("Save"),
                  onPressed: () async {
                    final updated = {
                      'rating': rating,
                      'comment': controller.text.trim(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    };
                    try {
                      await FirebaseFirestore.instance.collection('reviews').doc(reviewDocId).update(updated);
                      if (onUpdated != null) onUpdated!();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
                    }
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

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Delete Review"),
          content: const Text("Are you sure you want to delete this review?"),
          actions: [
            CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.pop(dialogContext)),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("Delete"),
              onPressed: () async {
                Navigator.pop(dialogContext); // close dialog
                try {
                  await FirebaseFirestore.instance.collection('reviews').doc(reviewDocId).delete();
                  if (onDeleted != null) onDeleted!();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

/// STAR DISPLAY
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
          return const Icon(CupertinoIcons.star_fill, size: 18, color: Color(0xFFFCC200));
        }
        if (i == full && half) {
          return const Icon(CupertinoIcons.star_lefthalf_fill, size: 18, color: Color(0xFFFCC200));
        }
        return const Icon(CupertinoIcons.star, size: 18, color: CupertinoColors.systemGrey);
      }),
    );
  }
}

/// EDITABLE STARS (used in edit dialog)
class _EditableStars extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;
  const _EditableStars({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        return GestureDetector(
          onTap: () => onChanged((i + 1).toDouble()),
          child: Icon(filled ? CupertinoIcons.star_fill : CupertinoIcons.star, size: 27, color: filled ? const Color(0xFFFCC200) : CupertinoColors.systemGrey),
        );
      }),
    );
  }
}

/// Fullscreen page — same as before with back button
class _YoutubeFullScreenPage extends StatefulWidget {
  final String videoId;
  const _YoutubeFullScreenPage({required this.videoId});

  @override
  State<_YoutubeFullScreenPage> createState() => _YoutubeFullScreenPageState();
}

class _YoutubeFullScreenPageState extends State<_YoutubeFullScreenPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          YoutubePlayer(controller: _controller),
          Positioned(
            top: 24,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
