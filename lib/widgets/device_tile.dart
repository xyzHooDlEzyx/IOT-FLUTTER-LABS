import 'package:flutter/material.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    required this.name,
    required this.location,
    required this.status,
    required this.icon,
    super.key,
    this.trailing,
  });

  final String name;
  final String location;
  final String status;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: scheme.secondary.withValues(alpha: 0.15),
            child: Icon(icon, color: scheme.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(location),
              ],
            ),
          ),
          trailing ??
              Text(
                status,
                style: Theme.of(context).textTheme.labelLarge,
              ),
        ],
      ),
    );
  }
}
