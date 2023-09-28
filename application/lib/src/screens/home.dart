import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common_widgets/category_widget.dart';
import '../common_widgets/custom_alert_dialog.dart';
import '../common_widgets/custom_app_bar.dart';
import '../common_widgets/no_data.dart';
import '../models/category.dart';
import '../screens/new_category.dart';
import '../services/auth.dart';
import '../services/category_service.dart';
import '../utils/color_string.dart';
import '../utils/global_variables.dart';
import '../utils/list_object.dart';
import '../utils/sort_function.dart';
import '../utils/utils.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  final User? user = Auth().currentUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ListObject> _categories = [];
  bool _isLoading = true;
  bool _selecting = false;
  Sort _currentSort = Sort.nameAsc;
  int _categoriesSelected = 0;
  final CategoryService categoryService = CategoryService();

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

  void addOrUpdate(
      String id, String name, String color, bool add, bool category) async {
    if (category) {
      Category categoryData = Category(id: id, name: name, color: color);
      add
          ? categoryService.addCategory(
              categoryData,
              AppLocalizations.of(context)!.toBuy,
              AppLocalizations.of(context)!.storage,
            )
          : categoryService.updateCategory(categoryData);
    }
    updateItemWidgetState();
  }

  void _fetchCategories() async {
    try {
      List<Category> categories = await categoryService.getCategories();
      setState(() {
        List<ListObject> list = [];
        for (var category in categories) {
          list.add(ListObject(category));
        }
        list.sort(getSortFunction(_currentSort));
        _categories = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _manageCategories(Option option) async {
    try {
      for (var category in _categories) {
        if (category.isSelected) {
          if (option == Option.copy) {
            categoryService.copyCategory(category.data);
          }
          if (option == Option.delete) {
            categoryService.deleteCategory(category.data.id);
          }
        }
      }
      setState(() {
        for (int i = 0; i < _categories.length; i++) {
          _categories.elementAt(i).isSelected = false;
        }
        _selecting = false;
        _categoriesSelected = 0;
      });
    } catch (e) {
      String message = '';
      switch (option) {
        case Option.copy:
          message = AppLocalizations.of(context)!.failedToCopyCategories;
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
              setState(() {
                _categories[index].isSelected = !_categories[index].isSelected;
                if (_categories[index].isSelected) {
                  _categoriesSelected++;
                } else {
                  _categoriesSelected--;
                }
              });
            }
          },
          onLongPress: () {
            setState(() {
              _categories[index].isSelected = true;
              _selecting = true;
              _categoriesSelected++;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            color: _categories[index].isSelected
                ? GlobalVariables.selectedColor
                : null,
            child: ListItem(
              id: _categories[index].data.id,
              text: _categories[index].data.name,
              color: stringToColor(_categories[index].data.color),
              defaultSubcategory: DefaultSubcategory.not,
              categoryId: null,
              fun: updateItemWidgetState,
              newFun: addOrUpdate,
              isAnySelected: _selecting,
            ),
          ),
        ),
        index == _categories.length - 1
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
      backgroundColor: GlobalVariables.appBarBoxColor,
      appBar: PreferredSize(
        preferredSize: GlobalVariables.appBarSize,
        child: CustomAppBar(
            color: GlobalVariables.appBarColor,
            text: AppLocalizations.of(context)!.lists,
            screen: Screen.categories,
            sortFunction: (Sort sort) {
              setState(() {
                if (_currentSort != sort) {
                  _categories.sort(getSortFunction(sort));
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
                            for (int i = 0; i < _categories.length; i++) {
                              _categories.elementAt(i).isSelected = false;
                            }
                            _selecting = false;
                            _categoriesSelected = 0;
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
                            for (int i = 0; i < _categories.length; i++) {
                              _categories.elementAt(i).isSelected =
                                  _categoriesSelected != _categories.length;
                            }
                            _categoriesSelected =
                                _categoriesSelected != _categories.length
                                    ? _categories.length
                                    : 0;
                          });
                        },
                        child: Text(
                          _categoriesSelected != _categories.length
                              ? AppLocalizations.of(context)!.all
                              : AppLocalizations.of(context)!.none,
                          style: GlobalVariables.textStyle2,
                        ),
                      ),
                      _categoriesSelected != 0
                          ? SizedBox(
                              width: 20.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text(
                                  _categoriesSelected.toString(),
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
                        if (_categories.any((item) => item.isSelected)) {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                CustomAlertDialog(
                              text1:
                                  '${AppLocalizations.of(context)!.copy} ${AppLocalizations.of(context)!.these} ${AppLocalizations.of(context)!.categories}?',
                              text2: AppLocalizations.of(context)!
                                  .doYouWantToCopyCategories,
                            ),
                          ).then((value) {
                            if (value == 'OK') {
                              _manageCategories(Option.copy).then((value) {
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
                        if (_categories.any((item) => item.isSelected)) {
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
                              _manageCategories(Option.delete).then((value) {
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
              : _categories.isEmpty
                  ? const NoData()
                  : Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ListView.builder(
                          itemCount: _categories.length,
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
                categoryId: null,
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
