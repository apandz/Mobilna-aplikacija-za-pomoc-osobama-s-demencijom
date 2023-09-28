import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import '../../common_widgets/custom_settings_button.dart';
import '../../services/auth.dart';
import '../../utils/global_variables.dart';
import '../../utils/utils.dart';
import '../auth/login.dart';
import 'password_change.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = Auth().currentUser!.email!;
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<bool> checkConnection() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
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
          AppLocalizations.of(context)!.account,
          style: GlobalVariables.textStyle1,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                label: Text(
                  AppLocalizations.of(context)!.email,
                  style: GlobalVariables.textStyle2.copyWith(
                    color: GlobalVariables.textFieldColor2,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              readOnly: true,
              canRequestFocus: false,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          CustomSettingsButton(
            text: AppLocalizations.of(context)!.changePassword,
            onPressed: () {
              checkConnection().then((value) {
                if (value) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PasswordChangeScreen(),
                    ),
                  );
                } else {
                  showSnackBar(
                      context, AppLocalizations.of(context)!.noInternet);
                }
              });
            },
          ),
          const Spacer(),
          CustomSettingsButton(
            text: AppLocalizations.of(context)!.signOut,
            centerText: true,
            onPressed: () {
              checkConnection().then(
                (value) {
                  if (value) {
                    showDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                          text1: AppLocalizations.of(context)!.signOut,
                          text2:
                              AppLocalizations.of(context)!.doYouWantToSignOut),
                    ).then((value) {
                      if (value == 'OK') {
                        signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    });
                  } else {
                    showSnackBar(
                        context, AppLocalizations.of(context)!.noInternet);
                  }
                },
              );
            },
          ),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
