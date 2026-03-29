import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: _editingDevice == null ? 'Add device' : 'Edit device',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingDevice == null
                  ? 'Add a new device to your IoT network'
                  : 'Update the device details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            AppTextField(
              label: 'Device name',
              hint: 'esp32_home',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Location',
              hint: 'Main corridor',
              controller: _locationController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Status',
              hint: 'Active',
              controller: _statusController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'MQTT broker URL',
              hint: 'broker.hivemq.com',
              controller: _mqttUrlController,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'MQTT topic',
              hint: 'sensor/temperature',
              controller: _topicController,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 140,
                  child: PrimaryButton(
                    label: 'Go back',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: PrimaryButton(
                    label:
                        _editingDevice == null ? 'Add device' : 'Save',
                    onPressed: _handleAdd,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
