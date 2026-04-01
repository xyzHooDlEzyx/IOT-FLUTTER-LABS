part of 'add_page.dart';

mixin _AddPageLayout on _AddPageLogic {
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
                    label: _editingDevice == null ? 'Add device' : 'Save',
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
