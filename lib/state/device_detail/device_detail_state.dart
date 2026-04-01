import 'package:my_project/domain/models/device_item.dart';

enum DeviceDetailStatus {
  idle,
  connecting,
  ready,
  error,
}

class DeviceDetailState {
  const DeviceDetailState({
    required this.status,
    this.device,
    this.connectionLabel = 'Disconnected',
    this.latestMessage = '-',
    this.latestFields = const {},
  });

  final DeviceDetailStatus status;
  final DeviceItem? device;
  final String connectionLabel;
  final String latestMessage;
  final Map<String, String> latestFields;

  DeviceDetailState copyWith({
    DeviceDetailStatus? status,
    DeviceItem? device,
    String? connectionLabel,
    String? latestMessage,
    Map<String, String>? latestFields,
  }) {
    return DeviceDetailState(
      status: status ?? this.status,
      device: device ?? this.device,
      connectionLabel: connectionLabel ?? this.connectionLabel,
      latestMessage: latestMessage ?? this.latestMessage,
      latestFields: latestFields ?? this.latestFields,
    );
  }

  static const DeviceDetailState idle = DeviceDetailState(
    status: DeviceDetailStatus.idle,
  );
}
