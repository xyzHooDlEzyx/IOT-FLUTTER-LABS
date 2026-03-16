import 'package:flutter/material.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_tile.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/section_title.dart';
import 'package:my_project/widgets/stat_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final statWidth = width < 600
      ? width
      : (width - 64) / 2;

    return AppShell(
      title: 'Urban IoT Grid',
      subtitle: 'Live overview of your connected spaces',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'City pulse'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Active hubs',
                        value: '24',
                        icon: Icons.wifi_tethering,
                      ),
                    ),
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Energy balance',
                        value: '92%',
                        icon: Icons.bolt,
                      ),
                    ),
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Alerts',
                        value: '3',
                        icon: Icons.notifications_active,
                      ),
                    ),
                    SizedBox(
                      width: statWidth,
                      child: const StatTile(
                        label: 'Sensors online',
                        value: '148',
                        icon: Icons.sensors,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: 'Recent devices'),
                SizedBox(height: 16),
                DeviceTile(
                  name: 'Air quality node',
                  location: 'District 4, Roof A',
                  status: 'Stable',
                  icon: Icons.air,
                ),
                SizedBox(height: 12),
                DeviceTile(
                  name: 'Traffic lidar',
                  location: 'Main boulevard',
                  status: 'Active',
                  icon: Icons.traffic,
                ),
                SizedBox(height: 12),
                DeviceTile(
                  name: 'Water flow',
                  location: 'South reservoir',
                  status: 'Syncing',
                  icon: Icons.water_drop,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  label: 'Open profile',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  label: 'Add device',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.add);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
