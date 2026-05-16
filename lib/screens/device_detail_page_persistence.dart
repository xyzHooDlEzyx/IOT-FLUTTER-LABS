part of 'device_detail_page.dart';

mixin _DeviceDetailPersistence on _DeviceDetailStateData {
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
}
