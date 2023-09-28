import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common_widgets/custom_app_bar.dart';
import '../common_widgets/custom_button.dart';
import '../common_widgets/custom_text_field.dart';
import '../utils/color_string.dart';
import '../utils/global_variables.dart';

class NewCategoryScreen extends StatefulWidget {
  final String? categoryId;
  final String? id;
  final DefaultSubcategory defaultSubcategory;
  final Color? color;
  final String? text;
  final Function addOrUpdate;

  const NewCategoryScreen({
    this.categoryId,
    this.id,
    required this.defaultSubcategory,
    this.color,
    this.text,
    required this.addOrUpdate,
    super.key,
  });

  @override
  State<NewCategoryScreen> createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  final nameController = TextEditingController();
  Color currentColor = GlobalVariables.colorPickerPrimary;

  @override
  void initState() {
    if (widget.text != null) {
      currentColor = widget.color!;
      nameController.text = widget.text!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: GlobalVariables.appBarBoxColor,
        appBar: PreferredSize(
          preferredSize: GlobalVariables.appBarSize,
          child: CustomAppBar(
            color: GlobalVariables.appBarColor,
            text: widget.text == null
                ? AppLocalizations.of(context)!.newCategory
                : AppLocalizations.of(context)!.editCategory,
            screen: Screen.other,
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            CustomTextField(
              label: AppLocalizations.of(context)!.name,
              controller: nameController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.color,
                  style: GlobalVariables.textStyle2
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.pickAColor,
                              style: GlobalVariables.textStyle1,
                            ),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                availableColors: GlobalVariables.categoryColors,
                                pickerColor: currentColor,
                                onColorChanged: (Color color) {
                                  setState(() {
                                    currentColor = color;
                                  });
                                },
                              ),
                            ),
                            actions: <Widget>[
                              CustomButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentColor,
                  ),
                  child: Container(
                    height: 40.0,
                    width: 80.0,
                    decoration: BoxDecoration(color: currentColor),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40.0,
            ),
            CustomButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  bool add = true;
                  bool category = true;
                  if (widget.text == null) {
                    if (widget.categoryId != null) {
                      category = false;
                    }
                  } else {
                    if (widget.categoryId == null) {
                      add = false;
                    } else {
                      add = false;
                      category = false;
                    }
                  }
                  if (category) {
                    widget.addOrUpdate(
                        add ? '' : widget.id,
                        nameController.text,
                        colorToString(currentColor),
                        add,
                        category);
                  } else {
                    widget.addOrUpdate(
                      add ? '' : widget.id,
                      nameController.text,
                      colorToString(currentColor),
                      add,
                      category,
                      widget.defaultSubcategory,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
