import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_project/domain/models/device_item.dart';
import 'package:my_project/state/devices/devices_cubit.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

part 'add_page_logic.dart';
part 'add_page_layout.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage>
    with _AddPageLogic, _AddPageLayout {}
