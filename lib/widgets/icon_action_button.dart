import 'package:flutter/material.dart';

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    super.key,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }
}
