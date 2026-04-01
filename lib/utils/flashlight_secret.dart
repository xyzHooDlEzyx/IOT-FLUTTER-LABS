import 'package:flashlight_flutter_plugin/flashlight_flutter_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> handleFlashlightSecretToggle(BuildContext context) async {
  final isAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  if (!isAndroid) {
    await _showUnsupportedDialog(context);
    return;
  }

  try {
    final isOn = await FlashlightFlutterPlugin.onLight();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOn ? 'Flashlight enabled.' : 'Flashlight disabled.',
        ),
      ),
    );
  } on PlatformException catch (error) {
    if (!context.mounted) {
      return;
    }
    final message = error.message ?? 'Flashlight is not available.';
    await _showUnsupportedDialog(context, message: message);
  }
}

Future<void> _showUnsupportedDialog(
  BuildContext context, {
  String? message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unsupported feature'),
      content: Text(
        message ?? 'Flashlight control is only supported on Android devices.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
