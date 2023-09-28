import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/category.dart';
import '../models/subcategory.dart';
import '../services/category_service.dart';
import '../services/subcategory_service.dart';
import '../utils/global_variables.dart';
import '../utils/info.dart';
import '../utils/sort_function.dart';

class CustomDialog extends StatefulWidget {
  final String categoryId;
  final String? subcategoryId;
  final bool move;
  final bool itemsScreen;

  const CustomDialog({
    super.key,
    required this.categoryId,
    this.subcategoryId,
    this.move = false,
    this.itemsScreen = false,
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
  String _categoryDropdownValue = '';
  String _subcategoryDropdownValue = '';
  bool _isLoading = true;
  bool _isLoadingSubcategories = true;

  void _fetchCategories() async {
    try {
      List<Category> categories = await CategoryService().getCategories();
      setState(() {
        if (widget.move && !widget.itemsScreen) {
          categories.removeWhere((element) => element.id == widget.categoryId);
        }
        categories.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _categories = categories;
        _categoryDropdownValue = (widget.move && !widget.itemsScreen)
            ? categories.first.id
            : widget.categoryId;
        _isLoading = false;
        if (widget.subcategoryId != null) {
          _fetchSubcategories();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchSubcategories() async {
    try {
      List<Subcategory> subcategories =
          await SubcategoryService(_categoryDropdownValue).getSubcategories();
      setState(() {
        if (widget.move) {
          subcategories
              .removeWhere((element) => element.id == widget.subcategoryId);
        }
        subcategories.sort((a, b) {
          int checkValue = check(a, b);
          if (checkValue != 0) {
            return checkValue;
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        _subcategories = subcategories;
        _subcategoryDropdownValue =
            widget.move ? subcategories.first.id : widget.subcategoryId!;
        _isLoadingSubcategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSubcategories = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    String text = AppLocalizations.of(context)!.copy;
    if (widget.move) {
      text = AppLocalizations.of(context)!.move;
    }
    text += ' ${AppLocalizations.of(context)!.these} ';
    text += widget.subcategoryId != null
        ? '${AppLocalizations.of(context)!.items}?'
        : '${AppLocalizations.of(context)!.categories}?';

    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Padding(
        padding: const EdgeInsets.only(
          bottom: 10.0,
          left: 20.0,
          right: 20.0,
        ),
        child: Text(
          text,
          style: GlobalVariables.textStyle1,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            AppLocalizations.of(context)!.toCategory,
            style: GlobalVariables.textStyle2.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Center(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: GlobalVariables.textFieldColor2,
                  ),
                )
              : DropdownMenu<String>(
                  initialSelection: _categoryDropdownValue,
                  textStyle: GlobalVariables.textStyle2,
                  onSelected: (String? value) {
                    setState(() {
                      _categoryDropdownValue = value!;
                      if (widget.subcategoryId != null) {
                        _isLoadingSubcategories = true;
                        _fetchSubcategories();
                      }
                    });
                  },
                  dropdownMenuEntries: _categories.map((Category value) {
                    return DropdownMenuEntry<String>(
                      value: value.id,
                      label: value.name,
                    );
                  }).toList(),
                ),
        ),
        widget.subcategoryId != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  AppLocalizations.of(context)!.toSubcategory,
                  style: GlobalVariables.textStyle2.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        widget.subcategoryId != null
            ? Center(
                child: _isLoadingSubcategories
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: GlobalVariables.textFieldColor2,
                        ),
                      )
                    : DropdownMenu<String>(
                        initialSelection: _subcategoryDropdownValue,
                        textStyle: GlobalVariables.textStyle2,
                        onSelected: (String? value) {
                          setState(() {
                            _subcategoryDropdownValue = value!;
                          });
                        },
                        dropdownMenuEntries:
                            _subcategories.map((Subcategory value) {
                          return DropdownMenuEntry<String>(
                            value: value.id,
                            label: value.name,
                          );
                        }).toList(),
                      ),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          height: 40.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                null,
              ),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GlobalVariables.textStyle2,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                Info(
                  categoryId: _categoryDropdownValue,
                  subcategoryId: _subcategoryDropdownValue,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: GlobalVariables.textStyle2
                    .copyWith(color: GlobalVariables.textFieldColor2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
