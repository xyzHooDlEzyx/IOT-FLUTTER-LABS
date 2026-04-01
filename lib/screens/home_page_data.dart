part of 'home_page.dart';

mixin _HomePageData on _HomePageActions {
  List<DeviceItem> _devices = const [];
  bool _isLoading = true;
  late final ShakeDetector _shakeDetector;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) {
        _showOverlayMessage('Shake detected');
        _showDoodleOverlay();
      },
      shakeThresholdGravity: 1.8,
      shakeSlopTimeMS: 300,
      useFilter: true,
    );
  }

  @override
  void dispose() {
    _shakeDetector.stopListening();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final devices = await DeviceStore.instance.getDevices();
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  Future<void> _saveDevices(List<DeviceItem> devices) async {
    await DeviceStore.instance.saveDevices(devices);
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
    });
  }

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
  }

  Future<void> _deleteDevice(DeviceItem device) async {
    final updated = List<DeviceItem>.from(_devices)
      ..removeWhere(
        (item) => item.id == device.id,
      );
    await _saveDevices(updated);
  }
}
