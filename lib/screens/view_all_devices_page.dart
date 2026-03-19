import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_list_item.dart';
import 'package:my_project/widgets/icon_action_button.dart';

class ViewAllDevicesPage extends StatefulWidget {
  const ViewAllDevicesPage({super.key});

  @override
  State<ViewAllDevicesPage> createState() => _ViewAllDevicesPageState();
}

class _ViewAllDevicesPageState extends State<ViewAllDevicesPage> {
  List<DeviceItem> _devices = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final devices = await DeviceStore.instance.getDevices();
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  Future<void> _openAdd({DeviceItem? device}) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.add,
      arguments: device,
    );
    if (result == true) {
      await _loadDevices();
    }
  }

  Future<void> _openDevice(DeviceItem device) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.deviceDetail,
      arguments: device,
    );
  }

  Future<void> _deleteDevice(DeviceItem device) async {
    final updated = List<DeviceItem>.from(_devices)
      ..removeWhere(
        (item) => item.id == device.id,
      );
    await DeviceStore.instance.saveDevices(updated);
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = updated;
    });
  }

  Future<void> _editDevice(DeviceItem device) async {
    await _openAdd(device: device);
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _openAdd,
                ),
              ],
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    Text(
                      'Loading devices...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else if (_devices.isEmpty)
                    Text(
                      'No devices found yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ..._devices.map(
                      (device) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: DeviceListItem(
                          device: device,
                          onTap: () => _openDevice(device),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) async {
                              if (action == 'edit') {
                                await _editDevice(device);
                              } else if (action == 'view') {
                                await _openDevice(device);
                              } else if (action == 'delete') {
                                await _deleteDevice(device);
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
            ),
          ],
        ),
      ),
    );
  }
}
