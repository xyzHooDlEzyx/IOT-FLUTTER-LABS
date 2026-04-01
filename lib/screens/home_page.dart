import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/screens/home_page_menu.dart';
import 'package:my_project/screens/home_page_recent_section.dart';
import 'package:my_project/screens/home_page_stats_section.dart';
import 'package:my_project/state/devices/devices_cubit.dart';
import 'package:my_project/state/devices/devices_state.dart';
import 'package:my_project/utils/flashlight_secret.dart';
import 'package:my_project/widgets/app_shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        if (state.status == DevicesStatus.idle) {
          context.read<DevicesCubit>().loadDevices();
        }

        return AppShell(
          title: 'Urban IoT Grid',
          subtitle: 'Live overview of your connected spaces',
          onTitleLongPress: () => handleFlashlightSecretToggle(context),
          trailing: IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => HomePageMenu.openMenuDrawer(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeStatsCard(
                statWidth: _statWidth(context),
                deviceCount: state.devices.length,
              ),
              const SizedBox(height: 24),
              HomeRecentDevicesCard(
                isLoading: state.isLoading,
                devices: state.devices,
                onAdd: ({device}) => _openAdd(context, device: device),
                onDelete: (device) =>
                    context.read<DevicesCubit>().deleteDevice(device),
                onOpenDevice: (device) => _openDevice(context, device),
                onViewAll: () async {
                  await Navigator.pushNamed(context, AppRoutes.viewAll);
                  if (!context.mounted) {
                    return;
                  }
                  await context.read<DevicesCubit>().loadDevices();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  double _statWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600 ? width : (width - 64) / 2;
  }

  Future<void> _openAdd(
    BuildContext context, {
    dynamic device,
  }) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.add,
      arguments: device,
    );
    if (!context.mounted) {
      return;
    }
    if (result == true) {
      await context.read<DevicesCubit>().loadDevices();
    }
  }

  Future<void> _openDevice(BuildContext context, dynamic device) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.deviceDetail,
      arguments: device,
    );
  }
}
