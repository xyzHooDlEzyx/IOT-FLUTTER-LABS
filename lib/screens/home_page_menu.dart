import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/theme_store.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/widgets/menu_drawer_panel.dart';

class HomePageMenu {
  static void openMenuDrawer(BuildContext context) {
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
              const SizedBox.expand(),
              Align(
                alignment: Alignment.centerRight,
                child: MenuDrawerPanel(
                  onActionSelected: (action) {
                    if (action != 'theme') {
                      Navigator.pop(context);
                    }
                    _handleMenuAction(context, action);
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

  static void _handleMenuAction(BuildContext context, String action) {
    if (action == 'theme') {
      ThemeStore.instance.cycleThemeMode();
      return;
    }
    if (action == 'profile') {
      Navigator.pushNamed(context, AppRoutes.profile);
      return;
    }
    if (action == 'logout') {
      context.read<AuthCubit>().logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon.')),
    );
  }
}
