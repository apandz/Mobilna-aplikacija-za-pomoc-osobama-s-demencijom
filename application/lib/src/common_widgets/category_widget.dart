import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/items.dart';
import '../screens/list.dart';
import '../screens/new_category.dart';
import '../services/category_service.dart';
import '../services/subcategory_service.dart';
import '../utils/global_variables.dart';
import 'custom_alert_dialog.dart';

class ListItem extends StatelessWidget {
  final String id;
  final String text;
  final Color color;
  final DefaultSubcategory defaultSubcategory;
  final String? categoryId;
  final String? categoryName;
  final Function newFun;
  final Function fun;
  final bool isAnySelected;
  final CategoryService categoryService = CategoryService();
  late final SubcategoryService subcategoryService =
      SubcategoryService(categoryId != null ? categoryId! : '');

  ListItem({
    Key? key,
    required this.id,
    required this.text,
    required this.color,
    required this.defaultSubcategory,
    this.categoryId,
    required this.newFun,
    required this.fun,
    this.isAnySelected = false,
    this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var padding = MediaQuery.of(context).viewPadding;
    int iconButtonN = 2;
    double iconButtonPadding = (iconButtonN + 3) * 10.0;
    Widget child = Container(
      width: width -
          padding.left -
          padding.right -
          iconButtonN * GlobalVariables.iconButtonSize -
          iconButtonPadding,
      height: 30.0,
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(5.0),
      color: color,
      child: Center(
        child: Text(
          text,
          style: GlobalVariables.textStyle2,
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 20.0,
            ),
            Material(
              child: InkWell(
                onTap: isAnySelected
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => categoryId == null
                                ? ListScreen(
                                    text: text,
                                    categoryId: id,
                                  )
                                : ItemsScreen(
                                    text: text,
                                    categoryName: categoryName!,
                                    categoryId: categoryId!,
                                    subcategoryId: id,
                                    defaultSubcategory: defaultSubcategory,
                                  ),
                          ),
                        );
                      },
                child: child,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            children: [
              SizedBox(
                width: GlobalVariables.iconButtonSize,
                height: GlobalVariables.iconButtonSize,
                child: IconButton(
                  onPressed: isAnySelected
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewCategoryScreen(
                                categoryId: categoryId,
                                id: id,
                                color: color,
                                text: text,
                                addOrUpdate: newFun,
                                defaultSubcategory: defaultSubcategory,
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
              defaultSubcategory.index == 0
                  ? SizedBox(
                      width: GlobalVariables.iconButtonSize,
                      height: GlobalVariables.iconButtonSize,
                      child: IconButton(
                        onPressed: isAnySelected
                            ? null
                            : () {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CustomAlertDialog(
                                    text1: AppLocalizations.of(context)!
                                        .deleteCategory,
                                    text2: AppLocalizations.of(context)!
                                        .doYouWantToDeleteCategory,
                                  ),
                                ).then((value) {
                                  if (value == 'OK') {
                                    if (categoryId == null) {
                                      categoryService.deleteCategory(id);
                                    } else {
                                      subcategoryService.deleteSubcategory(id);
                                    }
                                  }
                                  fun();
                                });
                              },
                        icon: SizedBox(
                          height: GlobalVariables.iconSize1,
                          width: GlobalVariables.iconSize1,
                          child: SvgPicture.asset(GlobalVariables.deleteIcon),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        )
      ],
    );
  }
}
