import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/state/devices/devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  DevicesCubit(this._deviceStore) : super(DevicesState.idle);

  final DeviceStore _deviceStore;

  Future<void> loadDevices() async {
    emit(state.copyWith(status: DevicesStatus.loading));
    try {
      final devices = await _deviceStore.getDevices();
      emit(
        state.copyWith(
          status: DevicesStatus.ready,
          devices: devices,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DevicesStatus.error,
          message: 'Failed to load devices.',
        ),
      );
    }
  }

  Future<void> saveDevice(DeviceItem device) async {
    final devices = await _ensureDevices();
    final updated = List<DeviceItem>.from(devices);
    final index = updated.indexWhere((item) => item.id == device.id);
    if (index >= 0) {
      updated[index] = device;
    } else {
      updated.add(device);
    }
    await _deviceStore.saveDevices(updated);
    emit(state.copyWith(status: DevicesStatus.ready, devices: updated));
  }

  Future<void> deleteDevice(DeviceItem device) async {
    final devices = await _ensureDevices();
    final updated = List<DeviceItem>.from(devices)
      ..removeWhere((item) => item.id == device.id);
    await _deviceStore.saveDevices(updated);
    emit(state.copyWith(status: DevicesStatus.ready, devices: updated));
  }

  Future<List<DeviceItem>> _ensureDevices() async {
    if (state.devices.isNotEmpty) {
      return state.devices;
    }
    return _deviceStore.getDevices();
  }
}
