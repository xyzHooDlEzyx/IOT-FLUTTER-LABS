import 'package:my_project/domain/models/device_item.dart';

enum DevicesStatus {
  idle,
  loading,
  ready,
  error,
}

class DevicesState {
  const DevicesState({
    required this.status,
    required this.devices,
    this.message,
  });

  final DevicesStatus status;
  final List<DeviceItem> devices;
  final String? message;

  bool get isLoading => status == DevicesStatus.loading;

  DevicesState copyWith({
    DevicesStatus? status,
    List<DeviceItem>? devices,
    String? message,
  }) {
    return DevicesState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      message: message,
    );
  }

  static const DevicesState idle = DevicesState(
    status: DevicesStatus.idle,
    devices: [],
  );
}
