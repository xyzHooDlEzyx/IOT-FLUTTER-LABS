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

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (error) {
      if (error.code != 'duplicate-app') {
        rethrow;
      }
    }
  }

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
