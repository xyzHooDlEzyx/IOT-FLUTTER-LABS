import 'dart:async';

import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/device_list_item.dart';
import 'package:my_project/widgets/icon_action_button.dart';

part 'view_all_devices_page_logic.dart';
part 'view_all_devices_page_actions.dart';
part 'view_all_devices_page_layout.dart';
part 'view_all_devices_status_dot.dart';

class ViewAllDevicesPage extends StatefulWidget {
  const ViewAllDevicesPage({super.key});

  @override
  State<ViewAllDevicesPage> createState() => _ViewAllDevicesPageState();
}

class _ViewAllDevicesPageState extends State<ViewAllDevicesPage>
  with _ViewAllDevicesConnections, _ViewAllDevicesActions, _ViewAllDevicesLayout {}
