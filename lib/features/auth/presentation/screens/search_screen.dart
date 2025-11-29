// lib/features/auth/presentation/screens/search_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../bloc/course_bloc.dart';
import '../../../courses/domain/course_model.dart';
import '../../data/models/app_user.dart';
import 'course_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _debounce;
  bool _loading = false;
  List<CourseModel> _results = [];
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(value.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _lastQuery = query;
      _loading = true;
    });

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    try {
      final start = query;
      final end = '$query\uf8ff';

      final prefixQuerySnapshot = await _firestore
          .collection('courses')
          .orderBy('title')
          .startAt([start])
          .endAt([end])
          .limit(40)
          .get();

      final prefixMatches = prefixQuerySnapshot.docs
          .map((d) => CourseModel.fromMap(d.id, d.data()))
          .toList();

      if (prefixMatches.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _results = prefixMatches;
          _loading = false;
        });
        return;
      }

      final fallbackSnapshot = await _firestore
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      final fallbackMatches = fallbackSnapshot.docs
          .map((d) => CourseModel.fromMap(d.id, d.data()))
          .where(
            (c) =>
                c.title.toLowerCase().contains(query.toLowerCase()) ||
                c.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _results = fallbackMatches;
        _loading = false;
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );

      print('Search error: $e\n$st');
    }
  }

  void _openCourseDetail(CourseModel course) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => CourseDetailScreen(courseId: course.id),
      ),
    );
  }

  // ---------------------------------------------------------
  // UPDATED: Empty states now show:
  //   "No courses found" IF user typed something
  //   "Type to search courses" IF no query yet
  // ---------------------------------------------------------
  Widget _buildEmptyState() {
    final bool hasTyped = _lastQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasTyped ? Icons.error_outline : Icons.search,
            size: 56,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            hasTyped ? 'No courses found' : 'Type to search courses',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(CourseModel course) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _openCourseDetail(course),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: _buildThumbnail(course),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          course.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(CupertinoIcons.right_chevron),
      ),
    );
  }

  Widget _buildThumbnail(CourseModel course) {
    final thumb = course.videoUrl;
    if (thumb != null && thumb.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          thumb,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book, color: Color(0xFF5B7FFF)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search courses'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CupertinoSearchTextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              placeholder: 'Search by title or description',
              prefixInsets: const EdgeInsetsDirectional.only(start: 8),
            ),
          ),

          // LOADING / RESULTS / NO RESULTS
          Expanded(
            child: _loading
                ? const Center(child: CupertinoActivityIndicator())
                : _results.isEmpty
                ? _buildEmptyState()
                : Scrollbar(
                    child: ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _results.length,
                      itemBuilder: (context, idx) {
                        final c = _results[idx];
                        return _buildResultTile(c);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
