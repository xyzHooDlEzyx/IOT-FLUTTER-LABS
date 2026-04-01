import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/screens/device_detail_metric_card.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/state/device_detail/device_detail_cubit.dart';
import 'package:my_project/state/device_detail/device_detail_state.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/info_row.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! DeviceItem) {
      return const AppShell(
        title: 'Device details',
        subtitle: 'Unknown device',
        child: AppCard(
          child: Text('No device data was provided.'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => DeviceDetailCubit(
        deviceStore: DeviceStore.instance,
      )..initialize(args),
      child: BlocBuilder<DeviceDetailCubit, DeviceDetailState>(
        builder: (context, state) {
          final device = state.device;
          if (device == null) {
            return const SizedBox.shrink();
          }

          return AppShell(
            title: 'Device details',
            subtitle: device.name,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.add,
                            arguments: device,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          if (result == true) {
                            await context
                                .read<DeviceDetailCubit>()
                                .reload(device.id);
                          }
                        },
                      ),
                    ],
                  ),
                  InfoRow(label: 'Name', value: device.name),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Location', value: device.location),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Status', value: device.status),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Topic', value: device.topic),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Connection', value: state.connectionLabel),
                  const SizedBox(height: 8),
                  if (state.latestFields.isEmpty)
                    InfoRow(
                      label: 'Latest payload',
                      value: state.latestMessage,
                    )
                  else ...[
                    Text(
                      'Latest values',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: state.latestFields.entries.map((entry) {
                        return DeviceDetailMetricCard(
                          label: entry.key,
                          value: entry.value,
                        );
                      }).toList(),
                    ),
                  ],
                  if (state.status == DeviceDetailStatus.connecting) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
