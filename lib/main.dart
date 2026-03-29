import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_project/app.dart';
import 'package:my_project/firebase_options.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/auth_store.dart';
import 'package:my_project/services/theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final isLoggedIn = await AuthStore.instance.isLoggedIn();
  await ThemeStore.instance.load();

  runApp(
    App(
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login,
    ),
  );
}
