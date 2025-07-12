import 'package:flutter/material.dart';

class HoverRevealCard extends StatefulWidget {
  final Widget frontContent;
  final Widget hiddenContent;
  final double height;
  final double width;

  const HoverRevealCard({
    Key? key,
    required this.frontContent,
    required this.hiddenContent,
    this.height = 180,
    this.width = 160,
  }) : super(key: key);

  @override
  _HoverRevealCardState createState() => _HoverRevealCardState();
}

class _HoverRevealCardState extends State<HoverRevealCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: _isHovering ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Front content (always visible)
            widget.frontContent,

            // Hidden content (reveals on hover)
            AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Transform.translate(
                offset: Offset(0, _isHovering ? 0 : 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: widget.hiddenContent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
