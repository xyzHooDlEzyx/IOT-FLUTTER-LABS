import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_list_item.dart';
import 'package:my_project/widgets/icon_action_button.dart';
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
    await _saveDevices(updated);
  }

  void _handleMenuAction(String action) {
    if (action == 'profile') {
      Navigator.pushNamed(context, AppRoutes.profile);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon.')),
    );
  }

  void _openMenuDrawer() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const SizedBox.expand(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 8,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  child: SizedBox(
                    width: 240,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.palette_outlined),
                            title: const Text('Theme'),
                            onTap: () {
                              Navigator.pop(context);
                              _handleMenuAction('theme');
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text('Settings'),
                            onTap: () {
                              Navigator.pop(context);
                              _handleMenuAction('settings');
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.person_outline),
                            title: const Text('Profile'),
                            onTap: () {
                              Navigator.pop(context);
                              _handleMenuAction('profile');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
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
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              onPressed: _openMenuDrawer,
            ),
          ),
          const SizedBox(height: 4),
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
                      child: StatTile(
                        label: 'Sensors online',
                        value: '${_devices.length}',
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.viewAll,
                          );
                          await _loadDevices();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        onPressed: _openAdd,
                      ),
                    ],
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
                      child: DeviceListItem(
                        device: device,
                        onTap: () => _openDevice(device),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'edit') {
                              await _openAdd(device: device);
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
    );
  }
}
