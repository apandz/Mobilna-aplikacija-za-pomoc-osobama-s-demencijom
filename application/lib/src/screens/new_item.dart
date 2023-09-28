import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../common_widgets/custom_alert_dialog.dart';
import '../common_widgets/custom_app_bar.dart';
import '../common_widgets/custom_button.dart';
import '../common_widgets/custom_text_field.dart';
import '../models/item.dart';
import '../utils/global_variables.dart';

class NewItemScreen extends StatefulWidget {
  final String categoryId;
  final String subcategoryId;
  final DefaultSubcategory defaultSubcategory;
  final Item? item;
  final bool read;
  final bool move;
  final Function addOrUpdate;

  const NewItemScreen({
    Key? key,
    required this.categoryId,
    required this.subcategoryId,
    this.item,
    this.read = false,
    this.move = false,
    required this.addOrUpdate,
    required this.defaultSubcategory,
  }) : super(key: key);

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final nameController = TextEditingController();
  final expirationDateController = TextEditingController();
  final quantityController = TextEditingController();
  final sizeController = TextEditingController();
  final notesController = TextEditingController();

  bool expirationDate = true;
  bool quantity = true;
  bool size = true;
  bool notes = true;

  String? nameErrorMessage;
  String? quantityErrorMessage;
  String? sizeErrorMessage;
  String? notesErrorMessage;

  @override
  void initState() {
    if (widget.item != null) {
      nameController.text = widget.item!.name;

      expirationDate = widget.item!.expirationDate != null;
      if (expirationDate) {
        expirationDateController.text = widget.item!.expirationDate!;
      }

      quantity = widget.item!.quantity != null;
      if (quantity) {
        quantityController.text = widget.item!.quantity!;
      }

      size = widget.item!.size != null;
      if (size) {
        sizeController.text = widget.item!.size!;
      }

      notes = widget.item!.notes != null;
      if (notes) {
        notesController.text = widget.item!.notes!;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.item == null
        ? AppLocalizations.of(context)!.newItem
        : AppLocalizations.of(context)!.editItem;
    if (widget.read) {
      title = AppLocalizations.of(context)!.itemDetails;
    }
    if (widget.move) {
      title = AppLocalizations.of(context)!.moveItem;
    }
    if (widget.item == null &&
        widget.defaultSubcategory != DefaultSubcategory.toBuy) {
      DateTime dateTimeNow = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy')
          .format(dateTimeNow.add(const Duration(days: 7)));
      expirationDateController.text = formattedDate;
    }

    List<Widget> list = [
      const SizedBox(
        height: 20.0,
      ),
      CustomTextField(
        label: AppLocalizations.of(context)!.name,
        controller: nameController,
        read: widget.read,
        errorMessage: nameErrorMessage,
      ),
    ];

    expirationDate = ((expirationDate || !widget.read) &&
            widget.defaultSubcategory != DefaultSubcategory.toBuy) ||
        (widget.move && widget.defaultSubcategory == DefaultSubcategory.toBuy);
    expirationDate = expirationDate &&
        !(widget.defaultSubcategory == DefaultSubcategory.storage &&
            widget.move);
    if (expirationDate) {
      list.add(CustomTextField(
        label: AppLocalizations.of(context)!.expirationDate,
        controller: expirationDateController,
        textFieldType: TextFieldType.date,
        read: widget.read,
      ));
    }
    if (quantity || !widget.read) {
      list.add(CustomTextField(
        label: AppLocalizations.of(context)!.quantity,
        controller: quantityController,
        read: widget.read,
        errorMessage: quantityErrorMessage,
      ));
    }
    if (size || !widget.read) {
      list.add(CustomTextField(
        label: AppLocalizations.of(context)!.size,
        controller: sizeController,
        read: widget.read,
        errorMessage: sizeErrorMessage,
      ));
    }
    if (notes || !widget.read) {
      list.add(CustomTextField(
        label: AppLocalizations.of(context)!.notes,
        controller: notesController,
        read: widget.read,
        textFieldType: TextFieldType.area,
        errorMessage: notesErrorMessage,
      ));
    }
    if (!widget.read) {
      list.add(CustomButton(
        onPressed: () {
          nameErrorMessage = null;
          quantityErrorMessage = null;
          sizeErrorMessage = null;
          notesErrorMessage = null;

          bool nameValid = nameController.text.isNotEmpty &&
              nameController.text.length <= 20;
          bool quantityValid = quantityController.text.length <= 10;
          bool sizeValid = sizeController.text.length <= 10;
          bool notesValid = notesController.text.length <= 300;

          if (nameValid && quantityValid && sizeValid && notesValid) {
            Item itemData = Item(
              id: widget.item == null ? '' : widget.item!.id,
              name: nameController.text,
              expirationDate: expirationDateController.text.isNotEmpty
                  ? expirationDateController.text
                  : null,
              quantity: quantityController.text.isNotEmpty
                  ? quantityController.text
                  : null,
              size: sizeController.text.isNotEmpty ? sizeController.text : null,
              notes:
                  notesController.text.isNotEmpty ? notesController.text : null,
            );

            if (widget.move) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => CustomAlertDialog(
                  text1: AppLocalizations.of(context)!.moveThisItem,
                  text2: AppLocalizations.of(context)!.doYouWantToMoveItem,
                ),
              ).then((value) {
                if (value == 'OK') {
                  Navigator.of(context).pop(itemData);
                }
              });
            } else {
              widget.addOrUpdate(
                itemData,
                widget.item == null,
                expirationDateChanged: widget.item != null &&
                    widget.item!.expirationDate !=
                        expirationDateController.text,
              );
              Navigator.of(context).pop(true);
            }
          } else {
            setState(() {
              if (!nameValid) {
                if (nameController.text.isEmpty) {
                  nameErrorMessage =
                      AppLocalizations.of(context)!.nameEmptyError;
                } else {
                  nameErrorMessage = AppLocalizations.of(context)!.nameError;
                }
              }
              if (!quantityValid) {
                quantityErrorMessage =
                    AppLocalizations.of(context)!.quantityAndSizeError;
              }
              if (!sizeValid) {
                sizeErrorMessage =
                    AppLocalizations.of(context)!.quantityAndSizeError;
              }
              if (!notesValid) {
                notesErrorMessage = AppLocalizations.of(context)!.notesError;
              }
            });
          }
        },
      ));
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: GlobalVariables.appBarBoxColor,
        appBar: PreferredSize(
          preferredSize: GlobalVariables.appBarSize,
          child: CustomAppBar(
            color: GlobalVariables.appBarColor,
            text: title,
            screen: Screen.other,
          ),
        ),
        body: ListView(
          children: list,
        ),
      ),
    );
  }
}
