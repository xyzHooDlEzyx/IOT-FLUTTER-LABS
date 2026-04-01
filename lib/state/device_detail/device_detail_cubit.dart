import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/state/device_detail/device_detail_state.dart';

class DeviceDetailCubit extends Cubit<DeviceDetailState> {
  DeviceDetailCubit({
    required DeviceStore deviceStore,
  })  : _deviceStore = deviceStore,
        _mqttService = MqttService(),
        super(DeviceDetailState.idle);

  final DeviceStore _deviceStore;
  final MqttService _mqttService;
  StreamSubscription<String>? _messageSub;
  StreamSubscription<bool>? _connectionSub;
  Timer? _messageTimer;
  String? _pendingMessage;

  Future<void> initialize(DeviceItem device) async {
    emit(state.copyWith(device: device));
    await _loadLastPayload(device.id);
    await _connectMqtt(device);
  }

  Future<void> reload(String deviceId) async {
    await _loadLastPayload(deviceId);
    final device = state.device;
    if (device != null) {
      await _connectMqtt(device);
    }
  }

  Future<void> _loadLastPayload(String deviceId) async {
    final devices = await _deviceStore.getDevices();
    final device = devices.firstWhere(
      (item) => item.id == deviceId,
      orElse: () => state.device!,
    );
    emit(
      state.copyWith(
        device: device,
        latestMessage:
            device.lastPayload.isEmpty ? '-' : device.lastPayload,
        latestFields: _parsePayload(device.lastPayload),
      ),
    );
  }

  Future<void> _connectMqtt(DeviceItem device) async {
    _mqttService.disconnect();
    if (device.mqttUrl.isEmpty || device.topic.isEmpty) {
      emit(state.copyWith(connectionLabel: 'MQTT not configured'));
      return;
    }

    emit(state.copyWith(status: DeviceDetailStatus.connecting));
    final connected = await _mqttService.connect(
      broker: device.mqttUrl,
      topic: device.topic,
      clientId: 'detail_${device.id}',
    );
    emit(
      state.copyWith(
        status: DeviceDetailStatus.ready,
        connectionLabel: connected ? 'Connected' : 'Connection failed',
      ),
    );

    _connectionSub?.cancel();
    _connectionSub = _mqttService.connectionStatus.listen((isConnected) {
      emit(
        state.copyWith(
          connectionLabel: isConnected ? 'Connected' : 'Disconnected',
        ),
      );
    });

    _messageSub?.cancel();
    _messageSub = _mqttService.messages.listen((message) {
      _pendingMessage = message;
      _messageTimer ??= Timer(const Duration(milliseconds: 300), () {
        final nextMessage = _pendingMessage;
        _pendingMessage = null;
        _messageTimer = null;
        if (nextMessage == null) {
          return;
        }
        emit(
          state.copyWith(
            latestMessage: nextMessage,
            latestFields: _parsePayload(nextMessage),
          ),
        );
        _saveLastPayload(nextMessage);
      });
    });
  }

  Future<void> _saveLastPayload(String payload) async {
    final device = state.device;
    if (device == null) {
      return;
    }
    final devices = await _deviceStore.getDevices();
    final updated = devices.map((item) {
      if (item.id == device.id) {
        return item.copyWith(lastPayload: payload);
      }
      return item;
    }).toList();
    await _deviceStore.saveDevices(updated);
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
  Future<void> close() async {
    await _messageSub?.cancel();
    await _connectionSub?.cancel();
    _messageTimer?.cancel();
    _mqttService.dispose();
    return super.close();
  }
}
