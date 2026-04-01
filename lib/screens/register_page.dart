import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_project/domain/models/local_user.dart';
import 'package:my_project/domain/validators/user_validator.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/state/auth/auth_state.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

part 'register_page_logic.dart';
part 'register_page_layout.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with _RegisterPageLogic, _RegisterPageLayout {}
