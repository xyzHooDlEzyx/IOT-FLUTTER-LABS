part of 'device_detail_page.dart';

mixin _DeviceDetailStateData on State<DeviceDetailPage> {
  final MqttService _mqttService = MqttService();
  StreamSubscription<String>? _messageSub;
  StreamSubscription<bool>? _connectionSub;
  Timer? _messageTimer;
  String? _pendingMessage;
  DeviceItem? _device;
  bool _didLoadDevice = false;
  bool _isConnecting = false;
  String _connectionLabel = 'Disconnected';
  String _latestMessage = '-';
  Map<String, String> _latestFields = const {};
}
