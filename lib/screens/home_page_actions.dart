part of 'home_page.dart';

mixin _HomePageActions on State<HomePage> {
  bool _isDoodleShowing = false;
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
}
