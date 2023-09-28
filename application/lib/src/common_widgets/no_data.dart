import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/global_variables.dart';

class NoData extends StatelessWidget {
  final bool category;
  const NoData({
    super.key,
    this.category = true,
  });

  @override
  Widget build(BuildContext context) {
    String text1 = '';
    if (category) {
      text1 = AppLocalizations.of(context)!.noCategories;
    } else {
      text1 = AppLocalizations.of(context)!.noItems;
    }
    text1 += '\n';
    text1 = AppLocalizations.of(context)!.clickThe;

    return Center(
      child: RichText(
        text: TextSpan(
          style: GlobalVariables.textStyle2
              .copyWith(fontWeight: FontWeight.normal),
          children: [
            TextSpan(text: text1),
            TextSpan(
                text: AppLocalizations.of(context)!.add,
                style: GlobalVariables.textStyle2),
            TextSpan(
                text: category
                    ? AppLocalizations.of(context)!.buttonToCreateACategory
                    : AppLocalizations.of(context)!.buttonToCreateAnItem),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
