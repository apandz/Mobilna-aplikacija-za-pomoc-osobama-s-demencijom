import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common_widgets/custom_settings_button.dart';
import '../../utils/global_variables.dart';
import 'language.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          AppLocalizations.of(context)!.settings,
          style: GlobalVariables.textStyle1,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Center(
            child: CustomSettingsButton(
              text: AppLocalizations.of(context)!.language,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LanguageScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
