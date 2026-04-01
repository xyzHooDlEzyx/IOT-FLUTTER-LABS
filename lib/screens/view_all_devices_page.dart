import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/screens/view_all_devices_status_dot.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/state/devices/view_all_devices_cubit.dart';
import 'package:my_project/state/devices/view_all_devices_state.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_list_item.dart';
import 'package:my_project/widgets/icon_action_button.dart';

class ViewAllDevicesPage extends StatelessWidget {
  const ViewAllDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ViewAllDevicesCubit(
        deviceStore: DeviceStore.instance,
      )..loadDevices(),
      child: BlocBuilder<ViewAllDevicesCubit, ViewAllDevicesState>(
        builder: (context, state) {
          return AppShell(
            title: 'All devices',
            subtitle: 'Everything connected to your workspace',
            child: Transform.translate(
              offset: const Offset(0, -24),
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
                        tooltip: 'Add device',
                        icon: Icons.add,
                        onPressed: () => _openAdd(context),
                      ),
                    ],
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.isLoading)
                          Text(
                            'Loading devices...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else if (state.devices.isEmpty)
                          Text(
                            'No devices found yet.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else
                          Column(
                            children: state.devices.map((device) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: DeviceListItem(
                                  device: device,
                                  onTap: () => _openDevice(context, device),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ViewAllDevicesStatusDot(
                                        isConnected:
                                            state.connectionMap[device.id] ??
                                                false,
                                      ),
                                      const SizedBox(width: 8),
                                      PopupMenuButton<String>(
                                        onSelected: (action) async {
                                          if (action == 'edit') {
                                            await _openAdd(context,
                                                device: device);
                                          } else if (action == 'view') {
                                            await _openDevice(
                                                context, device);
                                          } else if (action == 'delete') {
                                            await context
                                                .read<ViewAllDevicesCubit>()
                                                .deleteDevice(device);
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
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAdd(BuildContext context, {DeviceItem? device}) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.add,
      arguments: device,
    );
    if (!context.mounted) {
      return;
    }
    if (result == true) {
      await context.read<ViewAllDevicesCubit>().refresh();
    }
  }

  Future<void> _openDevice(BuildContext context, DeviceItem device) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.deviceDetail,
      arguments: device,
    );
    if (!context.mounted) {
      return;
    }
    await context.read<ViewAllDevicesCubit>().refresh();
  }
}
