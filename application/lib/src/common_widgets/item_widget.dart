import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/item.dart';
import '../screens/new_item.dart';
import '../services/item_service.dart';
import '../utils/global_variables.dart';
import 'custom_alert_dialog.dart';

class ItemWidget extends StatefulWidget {
  final Item item;
  final String categoryId;
  final String subcategoryId;
  final DefaultSubcategory defaultSubcategory;
  final String details;
  final Function addOrUpdate;
  final Function update;
  final Color? color;
  final bool isAnySelected;

  const ItemWidget({
    Key? key,
    required this.item,
    required this.categoryId,
    required this.subcategoryId,
    required this.defaultSubcategory,
    required this.details,
    required this.addOrUpdate,
    required this.update,
    this.color,
    this.isAnySelected = false,
  }) : super(key: key);

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  late final ItemService itemService =
      ItemService(widget.categoryId, widget.subcategoryId);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var padding = MediaQuery.of(context).viewPadding;
    int iconButtonN =
        widget.defaultSubcategory != DefaultSubcategory.not ? 3 : 2;
    double iconButtonPadding = (iconButtonN + 2) * 10.0;

    Widget child = Column(
      children: [
        SizedBox(
          width: width -
              padding.left -
              padding.right -
              iconButtonN * GlobalVariables.iconButtonSize -
              iconButtonPadding,
          child: Text(
            widget.item.name,
            style: GlobalVariables.textStyle2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        SizedBox(
          width: width -
              padding.left -
              padding.right -
              iconButtonN * GlobalVariables.iconButtonSize -
              iconButtonPadding,
          child: Text(
            widget.details,
            style: GlobalVariables.textStyle2.copyWith(
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              Material(
                color: widget.color,
                child: InkWell(
                  onTap: widget.isAnySelected
                      ? null
                      : () {
                          if (widget.color == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewItemScreen(
                                  categoryId: widget.categoryId,
                                  subcategoryId: widget.subcategoryId,
                                  item: widget.item,
                                  read: true,
                                  addOrUpdate: widget.addOrUpdate,
                                  defaultSubcategory: widget.defaultSubcategory,
                                ),
                              ),
                            );
                          }
                        },
                  child: child,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              widget.defaultSubcategory != DefaultSubcategory.not
                  ? SizedBox(
                      width: GlobalVariables.iconButtonSize,
                      height: GlobalVariables.iconButtonSize,
                      child: IconButton(
                        enableFeedback: false,
                        onPressed: widget.isAnySelected
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewItemScreen(
                                      categoryId: widget.categoryId,
                                      subcategoryId: widget.subcategoryId,
                                      item: widget.item,
                                      addOrUpdate: widget.addOrUpdate,
                                      move: true,
                                      defaultSubcategory:
                                          widget.defaultSubcategory,
                                    ),
                                  ),
                                ).then((newItem) {
                                  if (newItem != null) {
                                    itemService.deleteItem(newItem.id);
                                    widget.addOrUpdate(newItem, true,
                                        inDefaultSubcategory: true);
                                  }
                                });
                              },
                        icon: SizedBox(
                          height: GlobalVariables.iconSize1,
                          width: GlobalVariables.iconSize1,
                          child: SvgPicture.asset(widget.defaultSubcategory ==
                                  DefaultSubcategory.toBuy
                              ? GlobalVariables.doneIcon
                              : GlobalVariables.cartIcon),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                width: GlobalVariables.iconButtonSize,
                height: GlobalVariables.iconButtonSize,
                child: IconButton(
                  onPressed: widget.isAnySelected
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewItemScreen(
                                categoryId: widget.categoryId,
                                subcategoryId: widget.subcategoryId,
                                item: widget.item,
                                addOrUpdate: widget.addOrUpdate,
                                defaultSubcategory: widget.defaultSubcategory,
                              ),
                            ),
                          );
                        },
                  icon: SizedBox(
                    height: GlobalVariables.iconSize1,
                    width: GlobalVariables.iconSize1,
                    child: SvgPicture.asset(GlobalVariables.editIcon),
                  ),
                ),
              ),
              SizedBox(
                width: GlobalVariables.iconButtonSize,
                height: GlobalVariables.iconButtonSize,
                child: IconButton(
                  onPressed: widget.isAnySelected
                      ? null
                      : () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  CustomAlertDialog(
                                    text1: AppLocalizations.of(context)!
                                        .deleteItem,
                                    text2: AppLocalizations.of(context)!
                                        .doYouWantToDeleteItem,
                                  )).then((value) {
                            if (value == 'OK') {
                              itemService.deleteItem(widget.item.id);
                            }
                            widget.update();
                          });
                        },
                  icon: SizedBox(
                    height: GlobalVariables.iconSize1,
                    width: GlobalVariables.iconSize1,
                    child: SvgPicture.asset(GlobalVariables.deleteIcon),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
