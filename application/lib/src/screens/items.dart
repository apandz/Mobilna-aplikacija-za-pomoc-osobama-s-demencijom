import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common_widgets/custom_alert_dialog.dart';
import '../common_widgets/custom_app_bar.dart';
import '../common_widgets/custom_dialog.dart';
import '../common_widgets/item_widget.dart';
import '../common_widgets/no_data.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../utils/global_variables.dart';
import '../utils/info.dart';
import '../utils/list_object.dart';
import '../utils/sort_function.dart';
import '../utils/utils.dart';
import 'new_item.dart';

class ItemsScreen extends StatefulWidget {
  final String text;
  final String categoryName;
  final String categoryId;
  final String subcategoryId;
  final DefaultSubcategory defaultSubcategory;
  const ItemsScreen({
    super.key,
    required this.text,
    required this.categoryId,
    required this.subcategoryId,
    required this.defaultSubcategory,
    required this.categoryName,
  });

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<ListObject> _items = [];
  bool _isLoading = true;
  bool _selecting = false;
  Sort _currentSort = Sort.nameAsc;
  int _itemsSelected = 0;
  late final ItemService itemService =
      ItemService(widget.categoryId, widget.subcategoryId);

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void updateItemWidgetState() {
    setState(() {
      _fetchCategories();
    });
  }

  void addOrUpdate(Item itemData, bool add,
      {bool inDefaultSubcategory = false,
      bool expirationDateChanged = false}) async {
    if (widget.defaultSubcategory == DefaultSubcategory.not ||
        !inDefaultSubcategory) {
      add
          ? await itemService.addItem(
              itemData,
              widget.categoryName,
              widget.text,
              widget.subcategoryId,
              body: AppLocalizations.of(context)!.expiringSoon,
            )
          : await itemService.updateItem(itemData,
              expirationDateChanged: expirationDateChanged);
    } else {
      if (add) {
        itemService.addItemInDefaultSubcategory(
          widget.categoryId,
          itemData,
          widget.categoryName,
          widget.text,
          widget.defaultSubcategory,
          body: AppLocalizations.of(context)!.expiringSoon,
        );
      }
    }

    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      List<Item> items = await itemService.getItems();
      setState(() {
        List<ListObject> list = [];
        for (var item in items) {
          list.add(ListObject(item));
        }
        list.sort(getSortFunction(_currentSort));
        _items = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _manageItems(Option option, Info? value) async {
    try {
      ItemService? newItemService;
      if (option != Option.delete) {
        newItemService = ItemService(
          (value!).categoryId,
          (value).subcategoryId,
        );
      }
      for (var item in _items) {
        if (item.isSelected) {
          if (option != Option.delete) {
            newItemService!.addItem(
              item.data,
              widget.categoryName,
              widget.text,
              value!.subcategoryId,
              body: AppLocalizations.of(context)!.expiringSoon,
            );
          }
          if (option != Option.copy) {
            itemService.deleteItem(item.data.id);
          }
        }
      }
      setState(() {
        for (int i = 0; i < _items.length; i++) {
          _items.elementAt(i).isSelected = false;
        }
        _selecting = false;
        _itemsSelected = 0;
      });
    } catch (e) {
      String message = '';
      switch (option) {
        case Option.copy:
          message = AppLocalizations.of(context)!.failedToCopyItems;
          break;
        case Option.move:
          message = AppLocalizations.of(context)!.failedToMoveItems;
          break;
        default:
          message = AppLocalizations.of(context)!.failedToDeleteItems;
      }
      showSnackBar(context, message);
    }
  }

  Widget _getListObjectTile(BuildContext context, int index) {
    Item item = _items[index].data;
    String details = '';
    if (widget.defaultSubcategory != DefaultSubcategory.toBuy) {
      if (item.expirationDate != null) {
        details +=
            '${AppLocalizations.of(context)!.expirationDateShort}${item.expirationDate!}   ';
      }
    }
    if (item.quantity != null) {
      details +=
          '${AppLocalizations.of(context)!.quantityShort}${item.quantity!}   ';
    }
    if (item.size != null) {
      details += '${AppLocalizations.of(context)!.sizeShort}${item.size!}   ';
    }
    if (item.notes != null) {
      details += AppLocalizations.of(context)!.notes + item.notes!;
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (_selecting) {
              setState(() {
                _items[index].isSelected = !_items[index].isSelected;
                if (_items[index].isSelected) {
                  _itemsSelected++;
                } else {
                  _itemsSelected--;
                }
              });
            }
          },
          onLongPress: () {
            setState(() {
              _items[index].isSelected = true;
              _selecting = true;
              _itemsSelected++;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            color:
                _items[index].isSelected ? GlobalVariables.selectedColor : null,
            child: ItemWidget(
              categoryId: widget.categoryId,
              subcategoryId: widget.subcategoryId,
              defaultSubcategory: widget.defaultSubcategory,
              item: item,
              details: details,
              update: updateItemWidgetState,
              addOrUpdate: addOrUpdate,
              color: _items[index].isSelected
                  ? GlobalVariables.selectedColor
                  : null,
              isAnySelected: _selecting,
            ),
          ),
        ),
        index == _items.length - 1
            ? const SizedBox(
                height: 45.0,
              )
            : Center(
                child: Container(
                  color: GlobalVariables.grayColor,
                  height: 1.0,
                  width: MediaQuery.of(context).size.width - 40.0,
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: GlobalVariables.appBarSize,
        child: CustomAppBar(
            color: GlobalVariables.appBarColor,
            text: widget.text,
            screen: widget.defaultSubcategory == DefaultSubcategory.toBuy
                ? Screen.itemsToBuy
                : Screen.itemsOther,
            sortFunction: (Sort sort) {
              setState(() {
                if (_currentSort != sort) {
                  _items.sort(getSortFunction(sort));
                }
                _currentSort = sort;
              });
            }),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _selecting
              ? AppBar(
                  backgroundColor: Colors.white,
                  toolbarHeight: 40.0,
                  shadowColor: Colors.white,
                  leadingWidth: MediaQuery.of(context).size.width / 2,
                  leading: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < _items.length; i++) {
                              _items.elementAt(i).isSelected = false;
                            }
                            _selecting = false;
                            _itemsSelected = 0;
                          });
                        },
                        icon: SizedBox(
                          height: GlobalVariables.iconSize4,
                          width: GlobalVariables.iconSize4,
                          child: SvgPicture.asset(GlobalVariables.cancelIcon),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < _items.length; i++) {
                              _items.elementAt(i).isSelected =
                                  _itemsSelected != _items.length;
                            }
                            _itemsSelected = _itemsSelected != _items.length
                                ? _items.length
                                : 0;
                          });
                        },
                        child: Text(
                          _itemsSelected != _items.length
                              ? AppLocalizations.of(context)!.all
                              : AppLocalizations.of(context)!.none,
                          style: GlobalVariables.textStyle2,
                        ),
                      ),
                      _itemsSelected != 0
                          ? SizedBox(
                              width: 20.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text(
                                  _itemsSelected.toString(),
                                  style: GlobalVariables.textStyle2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 20.0,
                            ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (_items.any((item) => item.isSelected)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => CustomDialog(
                              categoryId: widget.categoryId,
                              subcategoryId: widget.subcategoryId,
                            ),
                          ).then((value) {
                            if (value != null) {
                              _manageItems(Option.copy, value).then((value) {
                                updateItemWidgetState();
                                showSnackBar(context,
                                    AppLocalizations.of(context)!.itemsCopied);
                              });
                            }
                          });
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.copy,
                        style: GlobalVariables.textStyle2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_items.any((item) => item.isSelected)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => CustomDialog(
                              categoryId: widget.categoryId,
                              subcategoryId: widget.subcategoryId,
                              move: true,
                              itemsScreen: true,
                            ),
                          ).then((value) {
                            if (value != null) {
                              _manageItems(Option.move, value).then((value) {
                                updateItemWidgetState();
                                showSnackBar(context,
                                    AppLocalizations.of(context)!.itemsMoved);
                              });
                            }
                          });
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.move,
                        style: GlobalVariables.textStyle2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_items.any((item) => item.isSelected)) {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                CustomAlertDialog(
                              text1:
                                  '${AppLocalizations.of(context)!.delete} ${AppLocalizations.of(context)!.these} ${AppLocalizations.of(context)!.items}?',
                              text2: AppLocalizations.of(context)!
                                  .doYouWantToDeleteItems,
                            ),
                          ).then((value) {
                            if (value == 'OK') {
                              _manageItems(Option.delete, null).then((value) {
                                updateItemWidgetState();
                                showSnackBar(context,
                                    AppLocalizations.of(context)!.itemsDeleted);
                              });
                            }
                          });
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete,
                        style: GlobalVariables.textStyle2,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: GlobalVariables.textFieldColor2,
                  ),
                )
              : _items.isEmpty
                  ? const NoData(
                      category: false,
                    )
                  : Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: _getListObjectTile,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GlobalVariables.grayColor,
        elevation: 0,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewItemScreen(
                categoryId: widget.categoryId,
                subcategoryId: widget.subcategoryId,
                addOrUpdate: addOrUpdate,
                defaultSubcategory: widget.defaultSubcategory,
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add_outlined,
          size: 30.0,
          shadows: null,
          color: GlobalVariables.fontColor,
        ),
      ),
    );
  }
}
