part of 'device_detail_page.dart';

mixin _DeviceDetailLayout on _DeviceDetailLogic {
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
