import 'package:flutter/material.dart';

import 'package:my_project/domain/models/local_user.dart';
import 'package:my_project/domain/validators/user_validator.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/auth_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/info_row.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/section_title.dart';

part 'profile_page_logic.dart';
part 'profile_page_layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with _ProfilePageLogic, _ProfilePageLayout {}
