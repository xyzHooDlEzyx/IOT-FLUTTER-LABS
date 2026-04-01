import 'package:flutter/material.dart';
import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/device_list_item.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/section_title.dart';

typedef DeviceCallback = Future<void> Function(DeviceItem device);
typedef OpenCallback = Future<void> Function();
typedef OptionalDeviceCallback = Future<void> Function({DeviceItem? device});

class HomeRecentDevicesCard extends StatelessWidget {
  const HomeRecentDevicesCard({
    required this.isLoading,
    required this.devices,
    required this.onAdd,
    required this.onDelete,
    required this.onOpenDevice,
    required this.onViewAll,
    super.key,
  });

  final bool isLoading;
  final List<DeviceItem> devices;
  final OptionalDeviceCallback onAdd;
  final DeviceCallback onDelete;
  final DeviceCallback onOpenDevice;
  final OpenCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final recentDevices = devices.take(3).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Recent devices',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: onViewAll,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconActionButton(
                  tooltip: 'Add device',
                  icon: Icons.add,
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Text(
              'Loading devices...',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else if (devices.isEmpty)
            Text(
              'No devices yet. Add one to get started.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...recentDevices.map(
              (device) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DeviceListItem(
                  device: device,
                  onTap: () => onOpenDevice(device),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'edit') {
                        await onAdd(device: device);
                      } else if (action == 'view') {
                        await onOpenDevice(device);
                      } else if (action == 'delete') {
                        await onDelete(device);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
