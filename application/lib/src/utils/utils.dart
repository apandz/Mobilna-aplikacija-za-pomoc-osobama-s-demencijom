import 'package:flutter/material.dart';

import 'global_variables.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: GlobalVariables.textStyle2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      showCloseIcon: true,
      closeIconColor: Colors.white,
    ),
  );
}
