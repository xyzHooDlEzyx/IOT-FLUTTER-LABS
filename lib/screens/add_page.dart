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

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final status = _statusController.text.trim();

    if (name.isEmpty || location.isEmpty || status.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all device fields.')),
      );
      return;
    }

    final devices = await DeviceStore.instance.getDevices();
    final updated = List<DeviceItem>.from(devices)
      ..add(
        DeviceItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          location: location,
          status: status,
        ),
      );

    await DeviceStore.instance.saveDevices(updated);
    if (!mounted) {
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Add device',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a new device to your IoT network',
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
                    label: 'Add device',
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