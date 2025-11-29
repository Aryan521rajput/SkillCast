// lib/features/auth/presentation/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/theme_controller.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(viewportFraction: 0.92);
    final pageIndex = useState(0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slides = [
      "assets/home/slide1.png",
      "assets/home/slide2.png",
      "assets/home/slide3.png",
      "assets/home/slide4.png",
    ];

    // Auto slide
    useEffect(() {
      Timer? timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (pageController.hasClients) {
          final next = (pageIndex.value + 1) % slides.length;
          pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
          pageIndex.value = next;
        }
      });

      return timer.cancel;
    }, []);

    final width = MediaQuery.of(context).size.width;
    final carouselHeight = width > 900 ? 360.0 : width * 0.56;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HERO SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF1A1D26), Color(0xFF0F1218)]
                        : const [Color(0xFFEFF3FF), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Welcome 👋",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _themeButton(isDark),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Text(
                      "Let’s continue your learning journey",
                      style: TextStyle(
                        fontSize: 15.5,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.85),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // SEARCH BAR
                    // SEARCH BAR
                    GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed("/search"),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1F222B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.20 : 0.12,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              size: 20,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Search courses, topics or instructors",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CAROUSEL
                    SizedBox(
                      height: carouselHeight,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: slides.length,
                        onPageChanged: (i) => pageIndex.value = i,
                        itemBuilder: (_, i) {
                          final scale = i == pageIndex.value ? 1.0 : 0.94;

                          return AnimatedScale(
                            scale: scale,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.28 : 0.16,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  color: isDark
                                      ? const Color(0xFF0B0E14)
                                      : const Color(0xFFF7F8FB),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: width * 0.88,
                                      height: carouselHeight,
                                      child: Image.asset(
                                        slides[i],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CAROUSEL INDICATORS
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: pageIndex.value == i ? 14 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: pageIndex.value == i
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // EXPLORE COURSES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Explore Courses",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // BROWSE ALL COURSES
              _browseTile(
                context,
                icon: CupertinoIcons.book_solid,
                title: "Browse all courses",
                onTap: () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed("/main", arguments: 1),
              ),

              const SizedBox(height: 24),

              // ⭐ NEW MOTIVATIONAL BLOCK
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Keep Learning 🌟",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B7FFF), Color(0xFF7C93FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Every step you take today brings you closer to your goals.\n\nKeep learning. Keep growing.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // THEME BUTTON
  Widget _themeButton(bool dark) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: dark ? Colors.white12 : Colors.black12,
          shape: BoxShape.circle,
        ),
        child: Icon(
          dark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
          size: 22,
          color: dark ? Colors.yellow[400] : Colors.blueGrey.shade700,
        ),
      ),
      onPressed: () => ThemeController.instance.toggleTheme(),
    );
  }

  // TILE BUILDER
  Widget _browseTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F222B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.16),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B7FFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(CupertinoIcons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
