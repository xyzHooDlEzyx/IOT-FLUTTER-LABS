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

part 'home_page_data.dart';
part 'home_page_actions.dart';
part 'home_page_menu.dart';
part 'home_page_layout.dart';
part 'home_page_sections.dart';
part 'home_page_stats_section.dart';
part 'home_page_recent_section.dart';
part 'home_page_doodle.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
  with _HomePageActions, _HomePageData, _HomePageMenu, _HomePageLayout {}
