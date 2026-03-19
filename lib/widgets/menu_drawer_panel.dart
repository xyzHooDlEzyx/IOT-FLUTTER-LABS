import 'package:flutter/material.dart';

class MenuDrawerPanel extends StatelessWidget {
  const MenuDrawerPanel({required this.onActionSelected, super.key});

  final ValueChanged<String> onActionSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: MediaQuery.of(context).size.height,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 8,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme'),
                onTap: () => onActionSelected('theme'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () => onActionSelected('settings'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () => onActionSelected('profile'),
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () => onActionSelected('logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
