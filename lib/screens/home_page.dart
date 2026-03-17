import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_tile.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/section_title.dart';
import 'package:my_project/widgets/stat_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Future<void> _saveDevices(List<DeviceItem> devices) async {
    await DeviceStore.instance.saveDevices(devices);
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
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
    await _saveDevices(updated);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final statWidth = width < 600 ? width : (width - 64) / 2;
    final recentDevices = _devices.take(3).toList();

    return AppShell(
      title: 'Urban IoT Grid',
      subtitle: 'Live overview of your connected spaces',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'City pulse'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Active hubs',
                        value: '24',
                        icon: Icons.wifi_tethering,
                      ),
                    ),
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Energy balance',
                        value: '92%',
                        icon: Icons.bolt,
                      ),
                    ),
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Alerts',
                        value: '3',
                        icon: Icons.notifications_active,
                      ),
                    ),
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Sensors online',
                        value: '148',
                        icon: Icons.sensors,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Recent devices',
                  trailing: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.viewAll);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  Text(
                    'Loading devices...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else if (_devices.isEmpty)
                  Text(
                    'No devices yet. Add one to get started.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...recentDevices.map(
                    (device) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceTile(
                        name: device.name,
                        location: device.location,
                        status: device.status,
                        icon: Icons.sensors,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteDevice(device),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 170,
                child: PrimaryButton(
                  label: 'Open profile',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
              ),
              SizedBox(
                width: 170,
                child: PrimaryButton(
                  label: 'Add device',
                  onPressed: _openAdd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
