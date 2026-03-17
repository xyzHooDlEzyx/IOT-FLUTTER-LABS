import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_tile.dart';
import 'package:my_project/widgets/primary_button.dart';

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

  Future<void> _openAdd() async {
    final result = await Navigator.pushNamed(context, AppRoutes.add);
    if (result == true) {
      await _loadDevices();
    }
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
    final result = await _showEditDialog(device);
    if (result == null) {
      return;
    }
    final updated = _devices.map((item) {
      if (item.id == result.id) {
        return result;
      }
      return item;
    }).toList();
    await DeviceStore.instance.saveDevices(updated);
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = updated;
    });
  }

  Future<DeviceItem?> _showEditDialog(DeviceItem device) async {
    final nameController = TextEditingController(text: device.name);
    final locationController = TextEditingController(text: device.location);
    final statusController = TextEditingController(text: device.status);

    final result = await showDialog<DeviceItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updated = device.copyWith(
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                  status: statusController.text.trim(),
                );
                Navigator.pop(context, updated);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'All devices',
      subtitle: 'Everything connected to your workspace',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceTile(
                        name: device.name,
                        location: device.location,
                        status: device.status,
                        icon: Icons.sensors,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editDevice(device),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteDevice(device),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Add device',
            onPressed: _openAdd,
          ),
          const SizedBox(height: 12),
          GhostButton(
            label: 'Back to profile',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
