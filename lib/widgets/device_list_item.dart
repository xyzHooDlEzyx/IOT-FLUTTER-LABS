import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/widgets/device_tile.dart';

class DeviceListItem extends StatelessWidget {
  const DeviceListItem({
    required this.device,
    super.key,
    this.onTap,
    this.trailing,
  });

  final DeviceItem device;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: DeviceTile(
            name: device.name,
            location: device.location,
            status: device.status,
            icon: Icons.sensors,
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}
