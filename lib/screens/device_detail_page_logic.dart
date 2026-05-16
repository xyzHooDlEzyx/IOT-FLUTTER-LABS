part of 'device_detail_page.dart';

mixin _DeviceDetailLogic on _DeviceDetailStateData, _DeviceDetailPersistence {

  @override
  void dispose() {
    _messageSub?.cancel();
    _connectionSub?.cancel();
    _messageTimer?.cancel();
    _mqttService.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDevice) {
      return;
    }
    _didLoadDevice = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DeviceItem) {
      _device = args;
      _loadLastPayload(args.id);
      _connectMqtt();
    }
  }

  Future<void> _loadLastPayload(String deviceId) async {
    final devices = await DeviceStore.instance.getDevices();
    final device = devices.firstWhere(
      (item) => item.id == deviceId,
      orElse: () => _device!,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _device = device;
      _latestMessage = device.lastPayload.isEmpty ? '-' : device.lastPayload;
      _latestFields = _parsePayload(_latestMessage);
    });
  }

  Future<void> _connectMqtt() async {
    final device = _device;
    if (device == null) {
      return;
    }

    _mqttService.disconnect();
    if (device.mqttUrl.isEmpty || device.topic.isEmpty) {
      setState(() {
        _connectionLabel = 'MQTT not configured';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _connectionLabel = 'Connecting...';
    });

    final connected = await _mqttService.connect(
      broker: device.mqttUrl,
      topic: device.topic,
      clientId: 'detail_${device.id}',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isConnecting = false;
      _connectionLabel = connected ? 'Connected' : 'Connection failed';
    });

    _connectionSub?.cancel();
    _connectionSub = _mqttService.connectionStatus.listen((isConnected) {
      if (!mounted) {
        return;
      }
      setState(() {
        _connectionLabel = isConnected ? 'Connected' : 'Disconnected';
      });
    });

    _messageSub?.cancel();
    _messageSub = _mqttService.messages.listen((message) {
      if (!mounted) {
        return;
      }
      _pendingMessage = message;
      _messageTimer ??= Timer(const Duration(milliseconds: 300), () {
        final nextMessage = _pendingMessage;
        _pendingMessage = null;
        _messageTimer = null;
        if (!mounted || nextMessage == null) {
          return;
        }
        setState(() {
          _latestMessage = nextMessage;
          _latestFields = _parsePayload(nextMessage);
        });
        _saveLastPayload(nextMessage);
      });
    });
  }

}
