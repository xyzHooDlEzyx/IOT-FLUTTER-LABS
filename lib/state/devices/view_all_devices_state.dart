import 'package:my_project/domain/models/device_item.dart';

enum ViewAllDevicesStatus {
  idle,
  loading,
  ready,
  error,
}

class ViewAllDevicesState {
  const ViewAllDevicesState({
    required this.status,
    required this.devices,
    required this.connectionMap,
    this.message,
  });

  final ViewAllDevicesStatus status;
  final List<DeviceItem> devices;
  final Map<String, bool> connectionMap;
  final String? message;

  bool get isLoading => status == ViewAllDevicesStatus.loading;

  ViewAllDevicesState copyWith({
    ViewAllDevicesStatus? status,
    List<DeviceItem>? devices,
    Map<String, bool>? connectionMap,
    String? message,
  }) {
    return ViewAllDevicesState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      connectionMap: connectionMap ?? this.connectionMap,
      message: message,
    );
  }

  static const ViewAllDevicesState idle = ViewAllDevicesState(
    status: ViewAllDevicesStatus.idle,
    devices: [],
    connectionMap: {},
  );
}
