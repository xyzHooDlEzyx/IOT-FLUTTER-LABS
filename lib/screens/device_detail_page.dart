import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/info_row.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({super.key});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final MqttService _mqttService = MqttService();
  StreamSubscription<String>? _messageSub;
  StreamSubscription<bool>? _connectionSub;
  DeviceItem? _device;
  bool _didLoadDevice = false;
  bool _isConnecting = false;
  String _connectionLabel = 'Disconnected';
  String _latestMessage = '-';
  Map<String, String> _latestFields = const {};

  @override
  void dispose() {
    _messageSub?.cancel();
    _connectionSub?.cancel();
    _mqttService.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDevice) {
      return;
    }
    _didLoadDevice = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DeviceItem) {
      _device = args;
      _loadLastPayload(args.id);
      _connectMqtt();
    }
  }

  Future<void> _loadLastPayload(String deviceId) async {
    final devices = await DeviceStore.instance.getDevices();
    final device = devices.firstWhere(
      (item) => item.id == deviceId,
      orElse: () => _device!,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _device = device;
      _latestMessage = device.lastPayload.isEmpty ? '-' : device.lastPayload;
      _latestFields = _parsePayload(_latestMessage);
    });
  }

  Future<void> _connectMqtt() async {
    final device = _device;
    if (device == null) {
      return;
    }

    _mqttService.disconnect();
    if (device.mqttUrl.isEmpty || device.topic.isEmpty) {
      setState(() {
        _connectionLabel = 'MQTT not configured';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _connectionLabel = 'Connecting...';
    });

    final connected = await _mqttService.connect(
      broker: device.mqttUrl,
      topic: device.topic,
      clientId: 'detail_${device.id}',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isConnecting = false;
      _connectionLabel = connected ? 'Connected' : 'Connection failed';
    });

    _connectionSub?.cancel();
    _connectionSub = _mqttService.connectionStatus.listen((isConnected) {
      if (!mounted) {
        return;
      }
      setState(() {
        _connectionLabel = isConnected ? 'Connected' : 'Disconnected';
      });
    });

    _messageSub?.cancel();
    _messageSub = _mqttService.messages.listen((message) {
      if (!mounted) {
        return;
      }
      setState(() {
        _latestMessage = message;
        _latestFields = _parsePayload(message);
      });
      _saveLastPayload(message);
    });
  }

  Future<void> _saveLastPayload(String payload) async {
    final device = _device;
    if (device == null) {
      return;
    }

    final devices = await DeviceStore.instance.getDevices();
    final updated = devices.map((item) {
      if (item.id == device.id) {
        return item.copyWith(lastPayload: payload);
      }
      return item;
    }).toList();
    await DeviceStore.instance.saveDevices(updated);
    if (!mounted) {
      return;
    }
    setState(() {
      _device = device.copyWith(lastPayload: payload);
    });
  }

  Map<String, String> _parsePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }
    } catch (_) {
      return const {};
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final device = _device;

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
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        AppRoutes.add,
                        arguments: device,
                      );
                      if (!mounted || result != true) {
                        return;
                      }
                      await _loadLastPayload(device.id);
                      await _connectMqtt();
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
              InfoRow(label: 'Connection', value: _connectionLabel),
              const SizedBox(height: 8),
              if (_latestFields.isEmpty)
                InfoRow(label: 'Latest payload', value: _latestMessage)
              else ...[
                Text(
                  'Latest values',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _latestFields.entries.map((entry) {
                    return _MetricCard(
                      label: entry.key,
                      value: entry.value,
                    );
                  }).toList(),
                ),
              ],
              if (_isConnecting) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
