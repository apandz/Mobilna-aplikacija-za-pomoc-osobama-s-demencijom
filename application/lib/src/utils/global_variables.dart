import 'package:flutter/material.dart';

enum DefaultSubcategory { not, toBuy, storage }

enum Option { copy, move, delete }

enum Screen { categories, subcategories, itemsToBuy, itemsOther, other }

enum Sort { nameAsc, nameDesc, expirationDateAsc, expirationDateDesc }

enum TextFieldType { normal, date, area, email, password }

class GlobalVariables {
  //textStyles
  static const TextStyle textStyle1 = TextStyle(
    fontSize: 18.0,
    color: fontColor,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle textStyle2 = TextStyle(
    fontSize: 16.0,
    color: fontColor,
    fontWeight: FontWeight.w600,
  );

  //iconSize
  static const double iconButtonSize = 50.0;
  static const double iconSize = 30.0;
  static const double iconSize1 = 25.0;
  static const double iconSize2 = 22.0;
  static const double iconSize3 = 20.0;
  static const double iconSize4 = 15.0;

  //colors
  static const Color selectedColor = Color.fromRGBO(205, 229, 255, 1);
  static const Color fontColor = Color(0xB2000000);
  static const Color grayColor = Color.fromARGB(255, 239, 239, 239);
  static const Color textFieldColor1 = Color.fromARGB(255, 212, 212, 212);
  static const Color textFieldColor2 = Color.fromRGBO(29, 102, 181, 1);
  static const Color colorPickerPrimary = Color.fromARGB(255, 135, 193, 255);
  static const List<Color> categoryColors = [
    Color.fromARGB(255, 255, 134, 134),
    Color.fromARGB(255, 255, 150, 121),
    Color.fromARGB(255, 255, 226, 123),
    Color.fromARGB(255, 191, 255, 123),
    Color.fromARGB(255, 126, 255, 165),
    Color.fromARGB(255, 136, 255, 249),
    colorPickerPrimary,
    Color.fromARGB(255, 161, 163, 255),
    Color.fromARGB(255, 190, 141, 255),
    Color.fromARGB(255, 245, 136, 255),
    Color.fromARGB(255, 255, 126, 188),
    Color.fromARGB(255, 226, 225, 225),
    Color.fromARGB(255, 172, 172, 172),
    Color.fromARGB(255, 182, 132, 89),
  ];
  //appBar
  static const Color appBarColor = grayColor;
  static const Color appBarBoxColor = Colors.white;
  static const Size appBarSize = Size.fromHeight(90.0);

  //icons
  static const String backIcon = "assets/images/icons/Back.svg";
  static const String cancelIcon = "assets/images/icons/Cancel.svg";
  static const String cartIcon = "assets/images/icons/Cart.svg";
  static const String deleteIcon = "assets/images/icons/Delete.svg";
  static const String doneIcon = "assets/images/icons/Done.svg";
  static const String editIcon = "assets/images/icons/Edit.svg";
  static const String googleIcon = "assets/images/icons/Google.svg";
  static const String settingsIcon = "assets/images/icons/Settings.svg";
  static const String sortIcon = "assets/images/icons/Sort.svg";
  static const String userIcon = "assets/images/icons/User.svg";

  //images
  static const String logoImage = "assets/images/Logo.svg";
}
