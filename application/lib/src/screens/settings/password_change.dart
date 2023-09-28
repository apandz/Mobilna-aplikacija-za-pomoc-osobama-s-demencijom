import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_text_field.dart';
import '../../services/auth.dart';
import '../../utils/global_variables.dart';
import '../../utils/utils.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  String? errorMessage = '';
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  Future<void> changePassword() async {
    try {
      String? authErrorMessage = await Auth().changePassword(
          oldPasswordController.text, newPasswordController.text);
      if (authErrorMessage == null) {
        errorMessage = '';
      } else {
        errorMessage = authErrorMessage;
      }
    } on FirebaseAuthException {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.changePasswordError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SizedBox(
            height: GlobalVariables.iconSize3,
            width: GlobalVariables.iconSize3,
            child: SvgPicture.asset(GlobalVariables.backIcon),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.changePassword,
          style: GlobalVariables.textStyle1,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            CustomTextField(
              label: AppLocalizations.of(context)!.oldPassword,
              controller: oldPasswordController,
              textFieldType: TextFieldType.password,
            ),
            CustomTextField(
              label: AppLocalizations.of(context)!.newPassword,
              controller: newPasswordController,
              textFieldType: TextFieldType.password,
            ),
            CustomTextField(
              label: AppLocalizations.of(context)!.confirmNewPassword,
              controller: confirmNewPasswordController,
              textFieldType: TextFieldType.password,
            ),
            errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: GlobalVariables.textStyle2.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.normal,
                        fontSize: 13.0,
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 10.0,
                  ),
            CustomButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmNewPasswordController.text) {
                  changePassword().then((value) {
                    if (errorMessage == null || errorMessage!.isEmpty) {
                      Navigator.of(context).pop();
                      showSnackBar(context,
                          AppLocalizations.of(context)!.passwordChanged);
                    } else {
                      Navigator.of(context).pop();
                      showSnackBar(context, errorMessage!);
                    }
                  });
                } else {
                  setState(() {
                    errorMessage =
                        AppLocalizations.of(context)!.noMatchPasswordError;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
