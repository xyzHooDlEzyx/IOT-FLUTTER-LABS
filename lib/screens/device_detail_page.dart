import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/info_row.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final device = args is DeviceItem ? args : null;

    return AppShell(
      title: 'Device details',
      subtitle: device?.name ?? 'Unknown device',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device == null)
              Text(
                'No device data was provided.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              Row(
                children: [
                  IconActionButton(
                    tooltip: 'Back',
                    icon: Icons.chevron_left,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  IconActionButton(
                    tooltip: 'Edit device',
                    icon: Icons.edit,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.add,
                        arguments: device,
                      );
                    },
                  ),
                ],
              ),
              InfoRow(label: 'Name', value: device.name),
              const SizedBox(height: 8),
              InfoRow(label: 'Location', value: device.location),
              const SizedBox(height: 8),
              InfoRow(label: 'Status', value: device.status),
            ],
          ],
        ),
      ),
    );
  }
}
