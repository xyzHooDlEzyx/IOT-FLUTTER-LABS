import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_project/app.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/auth_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final isLoggedIn = await AuthStore.instance.isLoggedIn();

  runApp(
    App(
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login,
    ),
  );
}
