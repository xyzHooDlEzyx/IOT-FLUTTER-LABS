part of 'add_page.dart';

mixin _AddPageLogic on State<AddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _mqttUrlController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  DeviceItem? _editingDevice;
  bool _didLoadDevice = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _statusController.dispose();
    _mqttUrlController.dispose();
    _topicController.dispose();
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
      _editingDevice = args;
      _nameController.text = args.name;
      _locationController.text = args.location;
      _statusController.text = args.status;
      _mqttUrlController.text = args.mqttUrl;
      _topicController.text = args.topic;
    }
  }

  Future<void> _handleAdd() async {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final status = _statusController.text.trim();
    final mqttUrl = _mqttUrlController.text.trim();
    final topic = _topicController.text.trim();

    if (name.isEmpty ||
        location.isEmpty ||
        status.isEmpty ||
        mqttUrl.isEmpty ||
        topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all device fields.')),
      );
      return;
    }

    final devices = await DeviceStore.instance.getDevices();
    final updated = List<DeviceItem>.from(devices);
    if (_editingDevice != null) {
      final device = _editingDevice!;
      final index = updated.indexWhere((item) => item.id == device.id);
      final next = device.copyWith(
        name: name,
        location: location,
        status: status,
        mqttUrl: mqttUrl,
        topic: topic,
      );
      if (index >= 0) {
        updated[index] = next;
      }
    } else {
      updated.add(
        DeviceItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          location: location,
          status: status,
          mqttUrl: mqttUrl,
          topic: topic,
        ),
      );
    }

    await DeviceStore.instance.saveDevices(updated);
    if (!mounted) {
      return;
    }
    Navigator.pop(context, true);
  }
}
