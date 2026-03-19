import 'package:flutter/material.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/screens/add_page.dart';
import 'package:my_project/screens/device_detail_page.dart';
import 'package:my_project/screens/home_page.dart';
import 'package:my_project/screens/login_page.dart';
import 'package:my_project/screens/profile_page.dart';
import 'package:my_project/screens/register_page.dart';
import 'package:my_project/screens/view_all_devices_page.dart';
import 'package:my_project/services/theme_store.dart';
import 'package:my_project/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({
    required this.initialRoute,
    super.key,
  });

  final String initialRoute;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeStore.instance,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'IoT Flutter Lab',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeStore.instance.themeMode,
          initialRoute: widget.initialRoute,
          routes: {
            AppRoutes.login: (context) => const LoginPage(),
            AppRoutes.register: (context) => const RegisterPage(),
            AppRoutes.home: (context) => const HomePage(),
            AppRoutes.profile: (context) => const ProfilePage(),
            AppRoutes.add: (context) => const AddPage(),
            AppRoutes.viewAll: (context) => const ViewAllDevicesPage(),
            AppRoutes.deviceDetail: (context) => const DeviceDetailPage(),
          },
        );
      },
    );
  }
}
