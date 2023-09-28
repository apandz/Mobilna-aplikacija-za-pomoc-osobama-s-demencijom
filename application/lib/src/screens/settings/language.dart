import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../main.dart';
import '../../utils/global_variables.dart';
import '../../utils/language.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _dropdownValue = '';
  bool _isLoading = true;

  @override
  void initState() {
    getLocale().then((value) {
      setState(() {
        _isLoading = false;
        _dropdownValue = value.languageCode;
      });
    });
    super.initState();
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
          AppLocalizations.of(context)!.language,
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
          _isLoading
              ? const CircularProgressIndicator(
                  color: GlobalVariables.textFieldColor2,
                )
              : Center(
                  child: DropdownMenu<String>(
                    leadingIcon: const Icon(Icons.flag),
                    initialSelection: _dropdownValue,
                    textStyle: GlobalVariables.textStyle2,
                    onSelected: (String? value) {
                      setState(() async {
                        if (value != null) {
                          setLocale(value)
                              .then((value) => MyApp.setLocale(context, value));
                          _dropdownValue = value;
                        }
                      });
                    },
                    dropdownMenuEntries: [
                      DropdownMenuEntry<String>(
                        value: 'en',
                        label: AppLocalizations.of(context)!.english,
                      ),
                      DropdownMenuEntry<String>(
                        value: 'bs',
                        label: AppLocalizations.of(context)!.bosnian,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
