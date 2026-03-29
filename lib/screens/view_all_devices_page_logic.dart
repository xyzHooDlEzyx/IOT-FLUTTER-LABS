part of 'view_all_devices_page.dart';

mixin _ViewAllDevicesConnections on State<ViewAllDevicesPage> {
  List<DeviceItem> _devices = const [];
  bool _isLoading = true;
  Future<List<DeviceItem>>? _devicesFuture;
  final Map<String, MqttService> _mqttClients = {};
  final Map<String, StreamSubscription<bool>> _connectionSubs = {};
  final Map<String, bool> _connectionMap = {};
  final Map<String, String> _connectionConfig = {};
  final Map<String, bool> _pendingConnections = {};
  Timer? _connectionTimer;
  String _syncKey = '';

  @override
  void initState() {
    super.initState();
    _devicesFuture = DeviceStore.instance.getDevices();
    _loadDevices();
  }

  @override
  void dispose() {
    for (final sub in _connectionSubs.values) {
      sub.cancel();
    }
    for (final client in _mqttClients.values) {
      client.dispose();
    }
    _connectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final future = DeviceStore.instance.getDevices();
    setState(() {
      _devicesFuture = future;
      _isLoading = true;
    });

    final devices = await future;
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
      _isLoading = false;
      _syncKey = '';
    });
    await _syncConnections(devices);
  }

  void _ensureConnectionsSynced() {
    if (_isLoading) {
      return;
    }
    final segments = _devices
        .map((device) => '${device.id}:${device.mqttUrl}:${device.topic}')
        .toList();
    final nextKey = segments.join('|');
    if (nextKey == _syncKey) {
      return;
    }
    _syncKey = nextKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncConnections(_devices);
    });
  }

  Future<void> _syncConnections(List<DeviceItem> devices) async {
    final activeIds = devices.map((device) => device.id).toSet();

    final removed = _mqttClients.keys
        .where((id) => !activeIds.contains(id))
        .toList();
    for (final id in removed) {
      await _connectionSubs[id]?.cancel();
      _connectionSubs.remove(id);
      _mqttClients[id]?.dispose();
      _mqttClients.remove(id);
      _connectionMap.remove(id);
      _connectionConfig.remove(id);
    }

    for (final device in devices) {
      final hasConfig = device.mqttUrl.isNotEmpty && device.topic.isNotEmpty;
      final configKey = '${device.mqttUrl}|${device.topic}';
      if (!hasConfig) {
        _connectionMap[device.id] = false;
        _connectionConfig.remove(device.id);
        continue;
      }
      final existingConfig = _connectionConfig[device.id];
      if (_mqttClients.containsKey(device.id) && existingConfig == configKey) {
        continue;
      }

      if (_mqttClients.containsKey(device.id)) {
        await _connectionSubs[device.id]?.cancel();
        _connectionSubs.remove(device.id);
        _mqttClients[device.id]?.dispose();
        _mqttClients.remove(device.id);
      }

      final client = MqttService();
      _mqttClients[device.id] = client;
      _connectionConfig[device.id] = configKey;
      _connectionSubs[device.id] =
          client.connectionStatus.listen((isConnected) {
        if (!mounted) {
          return;
        }
        _pendingConnections[device.id] = isConnected;
        _connectionTimer ??= Timer(const Duration(milliseconds: 300), () {
          if (!mounted) {
            return;
          }
          final updates = Map<String, bool>.from(_pendingConnections);
          _pendingConnections.clear();
          _connectionTimer = null;
          setState(() {
            _connectionMap.addAll(updates);
          });
        });
      });

      final connected = await client.connect(
        broker: device.mqttUrl,
        topic: device.topic,
        clientId: 'list_${device.id}',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _connectionMap[device.id] = connected;
      });
    }
  }

}
