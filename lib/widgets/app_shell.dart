import 'package:flutter/material.dart';
import 'package:my_project/widgets/responsive_center.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTitleLongPress,
    this.headerSpacing = 24,
    this.subtitleSpacing = 8,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTitleLongPress;
  final double headerSpacing;
  final double subtitleSpacing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final isDark = scheme.brightness == Brightness.dark;
    final gradientColors = isDark
        ? [
            background,
            const Color(0xFF121315),
            const Color(0xFF0B0B0B),
          ]
        : const [
            Color(0xFFF2F2F0),
            Color(0xFFE6ECEA),
            Color(0xFFF7F4EE),
          ];

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const padding = EdgeInsets.fromLTRB(20, 16, 20, 24);
              final minHeight = constraints.maxHeight - padding.vertical;

              return SingleChildScrollView(
                padding: padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: minHeight,
                  ),
                  child: ResponsiveCenter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (leading != null) ...[
                              leading!,
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onLongPress: onTitleLongPress,
                                    child: Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                  ),
                                  if (subtitle != null) ...[
                                    SizedBox(height: subtitleSpacing),
                                    Text(
                                      subtitle!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (trailing != null) ...[
                              const SizedBox(width: 8),
                              trailing!,
                            ],
                          ],
                        ),
                        SizedBox(height: headerSpacing),
                        child,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
