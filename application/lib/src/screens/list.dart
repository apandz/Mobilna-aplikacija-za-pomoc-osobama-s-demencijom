import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common_widgets/category_widget.dart';
import '../common_widgets/custom_alert_dialog.dart';
import '../common_widgets/custom_app_bar.dart';
import '../common_widgets/custom_dialog.dart';
import '../common_widgets/no_data.dart';
import '../models/subcategory.dart';
import '../services/subcategory_service.dart';
import '../utils/color_string.dart';
import '../utils/global_variables.dart';
import '../utils/list_object.dart';
import '../utils/sort_function.dart';
import '../utils/utils.dart';
import 'new_category.dart';

class ListScreen extends StatefulWidget {
  final String text;
  final String categoryId;
  const ListScreen({
    super.key,
    required this.text,
    required this.categoryId,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<ListObject> _subcategories = [];
  bool _isLoading = true;
  bool _selecting = false;
  Sort _currentSort = Sort.nameAsc;
  int _subcategoriesSelected = 0;
  late final SubcategoryService subcategoryService =
      SubcategoryService(widget.categoryId);

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

  void addOrUpdate(String id, String name, String color, bool add,
      bool category, DefaultSubcategory defaultSubcategory) async {
    if (!category) {
      Subcategory subcategoryData = Subcategory(
        id: id,
        name: name,
        color: color,
        defaultSubcategory: defaultSubcategory,
      );
      add
          ? await subcategoryService.addSubcategory(subcategoryData)
          : await subcategoryService.updateSubcategory(subcategoryData);
    }
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      List<Subcategory> subcategories =
          await subcategoryService.getSubcategories();
      setState(() {
        List<ListObject> list = [];
        for (var subcategory in subcategories) {
          list.add(ListObject(subcategory));
        }
        list.sort(getSortFunction(_currentSort));
        _subcategories = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _manageSubcategories(Option option, String? categoryId) async {
    try {
      SubcategoryService? newSubcategoryService;
      if (option != Option.delete) {
        newSubcategoryService = SubcategoryService(categoryId!);
      }
      for (var subcategory in _subcategories) {
        if (subcategory.isSelected) {
          if (option != Option.delete) {
            newSubcategoryService!
                .copySubcategory(subcategory.data, subcategoryService)
                .then((_) {
              if (option == Option.move) {
                subcategoryService.deleteSubcategory(subcategory.data.id);
                updateItemWidgetState();
              }
            });
          } else {
            subcategoryService.deleteSubcategory(subcategory.data.id);
          }
        }
      }
      setState(() {
        for (int i = 0; i < _subcategories.length; i++) {
          _subcategories.elementAt(i).isSelected = false;
        }
        _selecting = false;
        _subcategoriesSelected = 0;
      });
    } catch (e) {
      String message = '';
      switch (option) {
        case Option.copy:
          message = AppLocalizations.of(context)!.failedToCopyCategories;
          break;
        case Option.move:
          message = AppLocalizations.of(context)!.failedToMoveCategories;
          break;
        default:
          message = AppLocalizations.of(context)!.failedToDeleteCategories;
      }
      showSnackBar(context, message);
    }
  }

  Widget _getListObjectTile(BuildContext context, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (_selecting) {
              if (_subcategories[index].data.defaultSubcategory ==
                  DefaultSubcategory.not) {
                setState(() {
                  _subcategories[index].isSelected =
                      !_subcategories[index].isSelected;
                  if (_subcategories[index].isSelected) {
                    _subcategoriesSelected++;
                  } else {
                    _subcategoriesSelected--;
                  }
                });
              } else {
                showSnackBar(context,
                    AppLocalizations.of(context)!.defaultSubcategoriesError);
              }
            }
          },
          onLongPress: () {
            if (_subcategories[index].data.defaultSubcategory ==
                DefaultSubcategory.not) {
              setState(() {
                _subcategories[index].isSelected = true;
                _selecting = true;
                _subcategoriesSelected++;
              });
            } else {
              showSnackBar(context,
                  AppLocalizations.of(context)!.defaultSubcategoriesError);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            color: _subcategories[index].isSelected
                ? GlobalVariables.selectedColor
                : null,
            child: ListItem(
              id: _subcategories[index].data.id,
              text: _subcategories[index].data.name,
              color: stringToColor(_subcategories[index].data.color),
              defaultSubcategory: _subcategories[index].data.defaultSubcategory,
              categoryId: widget.categoryId,
              categoryName: widget.text,
              fun: updateItemWidgetState,
              newFun: addOrUpdate,
              isAnySelected: _selecting,
            ),
          ),
        ),
        index == _subcategories.length - 1
            ? const SizedBox(
                height: 45.0,
              )
            : Center(
                child: Container(
                  color: GlobalVariables.grayColor,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  height: 1.0,
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
            screen: Screen.subcategories,
            sortFunction: (Sort sort) {
              setState(() {
                if (_currentSort != sort) {
                  _subcategories.sort(getSortFunction(sort));
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
                            for (int i = 0; i < _subcategories.length; i++) {
                              _subcategories.elementAt(i).isSelected = false;
                            }
                            _selecting = false;
                            _subcategoriesSelected = 0;
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
                            for (int i = 0; i < _subcategories.length; i++) {
                              if (_subcategories
                                      .elementAt(i)
                                      .data
                                      .defaultSubcategory ==
                                  DefaultSubcategory.not) {
                                _subcategories.elementAt(i).isSelected =
                                    _subcategoriesSelected !=
                                        _subcategories.length - 2;
                              }
                            }
                            _subcategoriesSelected = _subcategoriesSelected !=
                                    _subcategories.length - 2
                                ? _subcategories.length - 2
                                : 0;
                          });
                        },
                        child: Text(
                          _subcategoriesSelected != _subcategories.length - 2
                              ? AppLocalizations.of(context)!.all
                              : AppLocalizations.of(context)!.none,
                          style: GlobalVariables.textStyle2,
                        ),
                      ),
                      _subcategoriesSelected != 0
                          ? SizedBox(
                              width: 20.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text(
                                  _subcategoriesSelected.toString(),
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
                        if (_subcategories.any((item) => item.isSelected)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => CustomDialog(
                              categoryId: widget.categoryId,
                            ),
                          ).then((value) {
                            if (value != null) {
                              _manageSubcategories(
                                      Option.copy, value.categoryId)
                                  .then((value) {
                                updateItemWidgetState();
                                showSnackBar(
                                    context,
                                    AppLocalizations.of(context)!
                                        .categoriesCopied);
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
                        if (_subcategories.any((item) => item.isSelected)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => CustomDialog(
                              categoryId: widget.categoryId,
                              move: true,
                            ),
                          ).then((value) {
                            if (value != null) {
                              _manageSubcategories(
                                      Option.move, value.categoryId)
                                  .then((value) {
                                updateItemWidgetState();
                                showSnackBar(
                                    context,
                                    AppLocalizations.of(context)!
                                        .categoriesMoved);
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
                        if (_subcategories.any((item) => item.isSelected)) {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                CustomAlertDialog(
                              text1:
                                  '${AppLocalizations.of(context)!.delete} ${AppLocalizations.of(context)!.these} ${AppLocalizations.of(context)!.categories}?',
                              text2: AppLocalizations.of(context)!
                                  .doYouWantToDeleteCategories,
                            ),
                          ).then((value) {
                            if (value == 'OK') {
                              _manageSubcategories(Option.delete, null)
                                  .then((value) {
                                updateItemWidgetState();
                                showSnackBar(
                                    context,
                                    AppLocalizations.of(context)!
                                        .categoriesDeleted);
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
              : _subcategories.isEmpty
                  ? const NoData()
                  : Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ListView.builder(
                          itemCount: _subcategories.length,
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
              builder: (context) => NewCategoryScreen(
                categoryId: widget.text,
                addOrUpdate: addOrUpdate,
                defaultSubcategory: DefaultSubcategory.not,
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
