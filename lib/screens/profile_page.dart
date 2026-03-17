import 'package:flutter/material.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/info_row.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/section_title.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Profile',
      subtitle: 'Your workspace identity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex Rivera',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Urban Lab',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const InfoRow(label: 'Role', value: 'IoT Operator'),
                const SizedBox(height: 8),
                const InfoRow(label: 'Region', value: 'Central Hub'),
                const SizedBox(height: 8),
                const InfoRow(label: 'Status', value: 'Verified'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: 'Quick actions'),
                SizedBox(height: 16),
                InfoRow(label: 'Scenes', value: '6'),
                SizedBox(height: 8),
                InfoRow(label: 'Automations', value: '12'),
                SizedBox(height: 8),
                InfoRow(label: 'Teams', value: '3'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Back to dashboard',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.home);
            },
          ),
        ],
      ),
    );
  }
}
