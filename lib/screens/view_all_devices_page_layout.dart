part of 'view_all_devices_page.dart';

mixin _ViewAllDevicesLayout on _ViewAllDevicesActions {
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
                  FutureBuilder<List<DeviceItem>>(
                    future: _devicesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Text(
                          'Loading devices...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }

                      final devices = snapshot.data ?? _devices;
                      if (devices.isEmpty) {
                        return Text(
                          'No devices found yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }

                      return Column(
                        children: devices.map((device) {
                          return Padding(
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
                          );
                        }).toList(),
                      );
                    },
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
