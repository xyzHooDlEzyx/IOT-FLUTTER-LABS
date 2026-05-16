import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/device_store.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/info_row.dart';

part 'device_detail_page_logic.dart';
part 'device_detail_page_data.dart';
part 'device_detail_page_persistence.dart';
part 'device_detail_page_layout.dart';
part 'device_detail_metric_card.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({super.key});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage>
  with
    _DeviceDetailStateData,
    _DeviceDetailPersistence,
    _DeviceDetailLogic,
    _DeviceDetailLayout {}
