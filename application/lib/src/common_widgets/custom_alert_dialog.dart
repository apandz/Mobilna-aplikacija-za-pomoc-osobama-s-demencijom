import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/global_variables.dart';

class CustomAlertDialog extends StatelessWidget {
  final String text1;
  final String text2;
  const CustomAlertDialog(
      {super.key, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        text1,
        style: GlobalVariables.textStyle1,
      ),
      content: Text(
        text2,
        style: GlobalVariables.textStyle2.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: GlobalVariables.textStyle2,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: GlobalVariables.textStyle2
                .copyWith(color: GlobalVariables.textFieldColor2),
          ),
        ),
      ],
    );
  }
}
