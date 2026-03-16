import 'package:flutter/material.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
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
            const SizedBox(height: 16),
            Text(
              'This feature is coming soon. Stay tuned for updates.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Back to home',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}