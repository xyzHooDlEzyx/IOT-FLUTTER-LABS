import 'dart:async';

import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/services/mqtt_service.dart';
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
  final Map<String, MqttService> _mqttClients = {};
  final Map<String, StreamSubscription<bool>> _connectionSubs = {};
  final Map<String, bool> _connectionMap = {};
  final Map<String, String> _connectionConfig = {};
  String _syncKey = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    for (final sub in _connectionSubs.values) {
      sub.cancel();
    }
    for (final client in _mqttClients.values) {
      client.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final devices = await DeviceStore.instance.getDevices();
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
      _isLoading = false;
      _syncKey = '';
    });
    await _syncConnections(devices);
  }

  void _ensureConnectionsSynced() {
    if (_isLoading) {
      return;
    }
    final segments = _devices
        .map((device) => '${device.id}:${device.mqttUrl}:${device.topic}')
        .toList();
    final nextKey = segments.join('|');
    if (nextKey == _syncKey) {
      return;
    }
    _syncKey = nextKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncConnections(_devices);
    });
  }

  Future<void> _syncConnections(List<DeviceItem> devices) async {
    final activeIds = devices.map((device) => device.id).toSet();

    final removed = _mqttClients.keys
        .where((id) => !activeIds.contains(id))
        .toList();
    for (final id in removed) {
      await _connectionSubs[id]?.cancel();
      _connectionSubs.remove(id);
      _mqttClients[id]?.dispose();
      _mqttClients.remove(id);
      _connectionMap.remove(id);
      _connectionConfig.remove(id);
    }

    for (final device in devices) {
      final hasConfig = device.mqttUrl.isNotEmpty && device.topic.isNotEmpty;
      final configKey = '${device.mqttUrl}|${device.topic}';
      if (!hasConfig) {
        _connectionMap[device.id] = false;
        _connectionConfig.remove(device.id);
        continue;
      }
      final existingConfig = _connectionConfig[device.id];
      if (_mqttClients.containsKey(device.id) && existingConfig == configKey) {
        continue;
      }

      if (_mqttClients.containsKey(device.id)) {
        await _connectionSubs[device.id]?.cancel();
        _connectionSubs.remove(device.id);
        _mqttClients[device.id]?.dispose();
        _mqttClients.remove(device.id);
      }

      final client = MqttService();
      _mqttClients[device.id] = client;
      _connectionConfig[device.id] = configKey;
      _connectionSubs[device.id] =
          client.connectionStatus.listen((isConnected) {
        if (!mounted) {
          return;
        }
        setState(() {
          _connectionMap[device.id] = isConnected;
        });
      });

      final connected = await client.connect(
        broker: device.mqttUrl,
        topic: device.topic,
        clientId: 'list_${device.id}',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _connectionMap[device.id] = connected;
      });
    }
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
    if (!mounted) {
      return;
    }
    await _loadDevices();
  }

  Future<void> _deleteDevice(DeviceItem device) async {
    await _connectionSubs[device.id]?.cancel();
    _connectionSubs.remove(device.id);
    _mqttClients[device.id]?.dispose();
    _mqttClients.remove(device.id);
    _connectionMap.remove(device.id);

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
    _ensureConnectionsSynced();

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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatusDot(
                                isConnected:
                                    _connectionMap[device.id] ?? false,
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
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
                            ],
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

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final color = isConnected
        ? const Color(0xFF1EB980)
        : Colors.grey.shade400;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
