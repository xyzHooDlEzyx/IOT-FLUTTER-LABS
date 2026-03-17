import 'dart:convert';

import 'package:my_project/data/repositories/device_repository.dart';
import 'package:my_project/data/storage/key_value_storage.dart';
import 'package:my_project/domain/models/device_item.dart';

class LocalDeviceRepository implements DeviceRepository {
  LocalDeviceRepository(this._storage);

  static const String _devicesKey = 'devices';

  final KeyValueStorage _storage;

  @override
  Future<List<DeviceItem>> getDevices() async {
    final data = await _storage.getString(_devicesKey);
    if (data == null || data.isEmpty) {
      final seed = _seedDevices();
      await saveDevices(seed);
      return seed;
    }

    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(DeviceItem.fromJson)
            .whereType<DeviceItem>()
            .toList();
      }
    } catch (_) {
      return [];
    }

    return [];
  }

  @override
  Future<void> saveDevices(List<DeviceItem> devices) async {
    final payload = devices.map((device) => device.toJson()).toList();
    final data = jsonEncode(payload);
    await _storage.setString(_devicesKey, data);
  }

  List<DeviceItem> _seedDevices() {
    return const [
      DeviceItem(
        id: 'seed-1',
        name: 'Air quality node',
        location: 'District 4, Roof A',
        status: 'Stable',
      ),
      DeviceItem(
        id: 'seed-2',
        name: 'Traffic lidar',
        location: 'Main boulevard',
        status: 'Active',
      ),
      DeviceItem(
        id: 'seed-3',
        name: 'Water flow',
        location: 'South reservoir',
        status: 'Syncing',
      ),
    ];
  }
}
