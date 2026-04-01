import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/state/devices/view_all_devices_state.dart';

class ViewAllDevicesCubit extends Cubit<ViewAllDevicesState> {
  ViewAllDevicesCubit({
    required DeviceStore deviceStore,
  })  : _deviceStore = deviceStore,
        super(ViewAllDevicesState.idle);

  final DeviceStore _deviceStore;
  final Map<String, MqttService> _clients = {};
  final Map<String, StreamSubscription<bool>> _subscriptions = {};
  final Map<String, String> _connectionConfig = {};
  final Map<String, bool> _pendingConnections = {};
  Timer? _connectionTimer;

  Future<void> loadDevices() async {
    emit(state.copyWith(status: ViewAllDevicesStatus.loading));
    final devices = await _deviceStore.getDevices();
    emit(
      state.copyWith(
        status: ViewAllDevicesStatus.ready,
        devices: devices,
      ),
    );
    await _syncConnections(devices);
  }

  Future<void> deleteDevice(DeviceItem device) async {
    await _subscriptions[device.id]?.cancel();
    _subscriptions.remove(device.id);
    _clients[device.id]?.dispose();
    _clients.remove(device.id);

    final updated = List<DeviceItem>.from(state.devices)
      ..removeWhere((item) => item.id == device.id);
    await _deviceStore.saveDevices(updated);
    emit(state.copyWith(status: ViewAllDevicesStatus.ready, devices: updated));
  }

  Future<void> refresh() async {
    await loadDevices();
  }

  Future<void> _syncConnections(List<DeviceItem> devices) async {
    final activeIds = devices.map((device) => device.id).toSet();
    final removed = _clients.keys
        .where((id) => !activeIds.contains(id))
        .toList();
    for (final id in removed) {
      await _subscriptions[id]?.cancel();
      _subscriptions.remove(id);
      _clients[id]?.dispose();
      _clients.remove(id);
      _connectionConfig.remove(id);
    }

    for (final device in devices) {
      final hasConfig = device.mqttUrl.isNotEmpty && device.topic.isNotEmpty;
      final configKey = '${device.mqttUrl}|${device.topic}';
      if (!hasConfig) {
        emit(
          state.copyWith(
            connectionMap: Map<String, bool>.from(state.connectionMap)
              ..[device.id] = false,
          ),
        );
        _connectionConfig.remove(device.id);
        continue;
      }
      final existingConfig = _connectionConfig[device.id];
      if (_clients.containsKey(device.id) && existingConfig == configKey) {
        continue;
      }

      if (_clients.containsKey(device.id)) {
        await _subscriptions[device.id]?.cancel();
        _subscriptions.remove(device.id);
        _clients[device.id]?.dispose();
        _clients.remove(device.id);
      }

      final client = MqttService();
      _clients[device.id] = client;
      _connectionConfig[device.id] = configKey;
      _subscriptions[device.id] = client.connectionStatus.listen((isConnected) {
        _pendingConnections[device.id] = isConnected;
        _connectionTimer ??= Timer(const Duration(milliseconds: 300), () {
          final nextMap = Map<String, bool>.from(state.connectionMap)
            ..addAll(_pendingConnections);
          _pendingConnections.clear();
          _connectionTimer = null;
          emit(state.copyWith(connectionMap: nextMap));
        });
      });

      final connected = await client.connect(
        broker: device.mqttUrl,
        topic: device.topic,
        clientId: 'list_${device.id}',
      );
      emit(
        state.copyWith(
          connectionMap: Map<String, bool>.from(state.connectionMap)
            ..[device.id] = connected,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    for (final client in _clients.values) {
      client.dispose();
    }
    _connectionTimer?.cancel();
    return super.close();
  }
}
