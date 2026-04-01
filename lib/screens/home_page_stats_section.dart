import 'package:flutter/material.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/section_title.dart';
import 'package:my_project/widgets/stat_tile.dart';

class HomeStatsCard extends StatelessWidget {
  const HomeStatsCard({
    required this.statWidth,
    required this.deviceCount,
    super.key,
  });

  final double statWidth;
  final int deviceCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                child: StatTile(
                  label: 'Sensors online',
                  value: '$deviceCount',
                  icon: Icons.sensors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
