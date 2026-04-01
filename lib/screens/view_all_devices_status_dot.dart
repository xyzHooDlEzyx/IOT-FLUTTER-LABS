import 'package:flutter/material.dart';

class ViewAllDevicesStatusDot extends StatelessWidget {
  const ViewAllDevicesStatusDot({
    required this.isConnected,
    super.key,
  });

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final color = isConnected
        ? const Color(0xFF1EB980)
        : Colors.grey.shade400;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
