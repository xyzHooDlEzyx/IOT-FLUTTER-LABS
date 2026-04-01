part of 'view_all_devices_page.dart';

mixin _ViewAllDevicesActions on _ViewAllDevicesConnections {
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
}
