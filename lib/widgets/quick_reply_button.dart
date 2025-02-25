import 'package:flutter/material.dart';
import '../models/quick_reply.dart';
import '../theme/app_theme.dart';

class QuickReplyButton extends StatefulWidget {
  final QuickReply quickReply;
  final VoidCallback onTap;
  final bool isSelected;

  const QuickReplyButton({
    Key? key,
    required this.quickReply,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<QuickReplyButton> createState() => _QuickReplyButtonState();
}

class _QuickReplyButtonState extends State<QuickReplyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.shortAnimation,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
    
    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    
    return MouseRegion(
      onEnter: (_) => _handleHoverChange(true),
      onExit: (_) => _handleHoverChange(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: AppTheme.shortAnimation,
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isSelected 
                      ? primary 
                      : (_isHovering ? primary.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
                  width: widget.isSelected ? 2 : 1,
                ),
                color: widget.isSelected 
                    ? primary.withOpacity(isDarkMode ? 0.3 : 0.1)
                    : (_isHovering 
                        ? primary.withOpacity(isDarkMode ? 0.15 : 0.05)
                        : Colors.transparent),
                boxShadow: _isHovering || widget.isSelected
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.quickReply.icon != null) ...[
                    AnimatedContainer(
                      duration: AppTheme.shortAnimation,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? primary.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.quickReply.icon,
                        size: 16,
                        color: widget.isSelected || _isHovering ? primary : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.quickReply.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isSelected || _isHovering ? primary : Colors.grey[600],
                      fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}