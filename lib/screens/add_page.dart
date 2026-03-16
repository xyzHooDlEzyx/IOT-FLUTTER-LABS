import 'package:flutter/material.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

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
            const AppTextField(
              label: 'Device Name',
              hint: 'esp32_home',
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'MQTT url',
              hint: 'localhost:8080',),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Topic name',
              hint: 'supertopic',
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'device(optional)',
              hint: 'esp_relay',),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 140,
                  child: PrimaryButton(
                    label: 'Go Back',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: PrimaryButton(
                    label: 'Add Device',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
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