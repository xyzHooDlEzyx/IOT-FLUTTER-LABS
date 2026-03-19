import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/auth_store.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/services/theme_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_list_item.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/menu_drawer_panel.dart';
import 'package:my_project/widgets/section_title.dart';
import 'package:my_project/widgets/stat_tile.dart';
import 'package:shake/shake.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DeviceItem> _devices = const [];
  bool _isLoading = true;
  late final ShakeDetector _shakeDetector;
  bool _isDoodleShowing = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) {
        _showOverlayMessage('Shake detected');
        _showDoodleOverlay();
      },
      shakeThresholdGravity: 1.8,
      shakeSlopTimeMS: 300,
      minimumShakeCount: 1,
      useFilter: true,
    );
  }

  @override
  void dispose() {
    _shakeDetector.stopListening();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final devices = await DeviceStore.instance.getDevices();
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  Future<void> _saveDevices(List<DeviceItem> devices) async {
    await DeviceStore.instance.saveDevices(devices);
    if (!mounted) {
      return;
    }
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _openAdd({DeviceItem? device}) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.add,
      arguments: device,
    );
    if (result == true) {
      await _loadDevices();
    }
  }

  Future<void> _openDevice(DeviceItem device) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.deviceDetail,
      arguments: device,
    );
  }

  Future<void> _deleteDevice(DeviceItem device) async {
    final updated = List<DeviceItem>.from(_devices)
      ..removeWhere(
        (item) => item.id == device.id,
      );
    await _saveDevices(updated);
  }

  void _handleMenuAction(String action) {
    if (action == 'theme') {
      _toggleThemeMode();
      return;
    }
    if (action == 'profile') {
      Navigator.pushNamed(context, AppRoutes.profile);
      return;
    }
    if (action == 'logout') {
      _logout();
      return;
    }

    _showOverlayMessage('Coming soon.');
  }

  Future<void> _logout() async {
    await AuthStore.instance.setLoggedIn(false);
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _toggleThemeMode() async {
    final mode = await ThemeStore.instance.cycleThemeMode();
    if (!mounted) {
      return;
    }
    final label = switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
    _showOverlayMessage('Theme: $label');
  }

  void _showOverlayMessage(String message) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Material(
                color: Theme.of(context).colorScheme.inverseSurface,
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Timer(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  void _showDoodleOverlay() {
    if (_isDoodleShowing) {
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _isDoodleShowing = true;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _DoodleOverlay(
          color: Theme.of(context).colorScheme.primary,
          onFinished: () {
            entry.remove();
            _isDoodleShowing = false;
          },
        );
      },
    );

    overlay.insert(entry);
  }

  void _openMenuDrawer() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const SizedBox.expand(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: MenuDrawerPanel(
                  onActionSelected: (action) {
                    if (action != 'theme') {
                      Navigator.pop(context);
                    }
                    _handleMenuAction(action);
                  },
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final statWidth = width < 600 ? width : (width - 64) / 2;
    final recentDevices = _devices.take(3).toList();

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
                      child: StatTile(
                        label: 'Sensors online',
                        value: '${_devices.length}',
                        icon: Icons.sensors,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Recent devices',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.viewAll,
                          );
                          await _loadDevices();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                              .withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View all',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconActionButton(
                        tooltip: 'Add device',
                        icon: Icons.add,
                        onPressed: _openAdd,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  Text(
                    'Loading devices...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else if (_devices.isEmpty)
                  Text(
                    'No devices yet. Add one to get started.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...recentDevices.map(
                    (device) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceListItem(
                        device: device,
                        onTap: () => _openDevice(device),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'edit') {
                              await _openAdd(device: device);
                            } else if (action == 'view') {
                              await _openDevice(device);
                            } else if (action == 'delete') {
                              await _deleteDevice(device);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'view',
                              child: Text('View'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoodleOverlay extends StatefulWidget {
  const _DoodleOverlay({
    required this.color,
    required this.onFinished,
  });

  final Color color;
  final VoidCallback onFinished;

  @override
  State<_DoodleOverlay> createState() => _DoodleOverlayState();
}

class _DoodleOverlayState extends State<_DoodleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final int _seed;

  @override
  void initState() {
    super.initState();
    _seed = DateTime.now().millisecondsSinceEpoch;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final fadeIn = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0, 0.2, curve: Curves.easeOut),
            ).value;
            final fadeOut = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.6, 1, curve: Curves.easeIn),
            ).value;
            final opacity = fadeIn * (1 - fadeOut);
            final scale = lerpDouble(0.9, 1, fadeIn) ?? 1;

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: CustomPaint(
                  painter: _DoodlePainter(
                    seed: _seed,
                    color: widget.color,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DoodlePainter extends CustomPainter {
  _DoodlePainter({
    required this.seed,
    required this.color,
  });

  final int seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final start = Offset(
      size.width * (0.2 + random.nextDouble() * 0.6),
      size.height * (0.2 + random.nextDouble() * 0.6),
    );
    path.moveTo(start.dx, start.dy);

    for (var i = 0; i < 18; i++) {
      final dx = (random.nextDouble() - 0.5) * 140;
      final dy = (random.nextDouble() - 0.5) * 140;
      final next = Offset(
        (path.getBounds().center.dx + dx).clamp(24, size.width - 24),
        (path.getBounds().center.dy + dy).clamp(24, size.height - 24),
      );
      path.quadraticBezierTo(
        next.dx + (random.nextDouble() - 0.5) * 40,
        next.dy + (random.nextDouble() - 0.5) * 40,
        next.dx,
        next.dy,
      );
    }

    canvas.drawPath(path, paint);

    final accentPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path.shift(const Offset(8, -8)), accentPaint);
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) {
    return oldDelegate.seed != seed || oldDelegate.color != color;
  }
}
