import 'package:intl/intl.dart';

import 'global_variables.dart';
import '../models/subcategory.dart';
import 'list_object.dart';

int check(dynamic a, dynamic b) {
  if (a.defaultSubcategory == DefaultSubcategory.toBuy ||
      (a.defaultSubcategory == DefaultSubcategory.storage &&
          b.defaultSubcategory != DefaultSubcategory.toBuy)) {
    return -1;
  }
  if (b.defaultSubcategory == DefaultSubcategory.toBuy ||
      (a.defaultSubcategory != DefaultSubcategory.toBuy &&
          b.defaultSubcategory == DefaultSubcategory.storage)) {
    return 1;
  }
  return 0;
}

int Function(ListObject<dynamic>, ListObject<dynamic>)? getSortFunction(
    Sort sort) {
  switch (sort) {
    case Sort.nameDesc:
      return (a, b) {
        if (a.data.runtimeType == Subcategory) {
          int checkValue = check(a.data, b.data);
          if (checkValue != 0) {
            return checkValue;
          }
        }
        return b.data.name.toLowerCase().compareTo(a.data.name.toLowerCase());
      };
    case Sort.expirationDateAsc:
      return (a, b) {
        if (a.data.expirationDate == null) {
          return 1;
        }
        if (b.data.expirationDate == null) {
          return -1;
        }
        return DateFormat('dd/MM/yyyy')
            .parse(a.data.expirationDate)
            .compareTo(DateFormat('dd/MM/yyyy').parse(b.data.expirationDate));
      };
    case Sort.expirationDateDesc:
      return (a, b) {
        if (a.data.expirationDate == null) {
          return 1;
        }
        if (b.data.expirationDate == null) {
          return -1;
        }
        return DateFormat('dd/MM/yyyy')
            .parse(b.data.expirationDate)
            .compareTo(DateFormat('dd/MM/yyyy').parse(a.data.expirationDate));
      };
    default:
  }
  return (a, b) {
    if (a.data.runtimeType == Subcategory) {
      int checkValue = check(a.data, b.data);
      if (checkValue != 0) {
        return checkValue;
      }
    }
    return a.data.name.toLowerCase().compareTo(b.data.name.toLowerCase());
  };
}
