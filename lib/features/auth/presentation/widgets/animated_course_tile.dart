import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedCourseTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedCourseTile({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedCourseTile> createState() => _AnimatedCourseTileState();
}

class _AnimatedCourseTileState extends State<AnimatedCourseTile> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),

      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) => setState(() => pressed = false),
        onTapCancel: () => setState(() => pressed = false),
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: (hovered || pressed)
              ? Matrix4.diagonal3Values(1.03, 1.03, 1)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(16),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(18),
          child: widget.child,
        ),
      ),
    );
  }
}
