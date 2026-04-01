part of 'home_page.dart';

mixin _HomePageLayout on _HomePageMenu, _HomePageData {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final statWidth = width < 600 ? width : (width - 64) / 2;
    return AppShell(
      title: 'Urban IoT Grid',
      subtitle: 'Live overview of your connected spaces',
      trailing: IconButton(
        icon: Icon(
          Icons.menu,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: _openMenuDrawer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeStatsCard(
            statWidth: statWidth,
            deviceCount: _devices.length,
          ),
          const SizedBox(height: 24),
          _HomeRecentDevicesCard(
            isLoading: _isLoading,
            devices: _devices,
            onAdd: _openAdd,
            onDelete: _deleteDevice,
            onOpenDevice: _openDevice,
            onViewAll: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.viewAll,
              );
              await _loadDevices();
            },
          ),
        ],
      ),
    );
  }
}
