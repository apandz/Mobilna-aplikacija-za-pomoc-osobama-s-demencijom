import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';
import '../models/subcategory.dart';
import '../utils/global_variables.dart';
import 'auth.dart';

class CategoryService {
  final CollectionReference categories = FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().currentUser!.uid)
      .collection('categories');

  Future getCategories() async {
    List<Category> categoriesList = [];
    try {
      QuerySnapshot snapshot = await categories.get();
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            categoriesList.add(
                Category(id: doc.id, name: data['name'], color: data['color']));
          }
        }
      }
    } catch (e) {
      return [];
    }
    return categoriesList;
  }

  Future addCategory(Category category, String toBuy, String storage) async {
    try {
      DocumentReference newCategoryRef = await categories.add(category.toMap());

      await newCategoryRef.collection('subcategories').doc().set({
        'id': '',
        'name': toBuy,
        'color': category.color,
        'defaultSubcategory': 1,
      });
      await newCategoryRef.collection('subcategories').doc().set({
        'id': '',
        'name': storage,
        'color': category.color,
        'defaultSubcategory': 2,
      });
    } catch (e) {
      return false;
    }
    return true;
  }

  Future getSubcategories(String categoryId) async {
    List<Subcategory> subcategoriesList = [];
    try {
      QuerySnapshot snapshot =
          await categories.doc(categoryId).collection('subcategories').get();
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            subcategoriesList.add(Subcategory(
              id: doc.id.toString(),
              name: data['name'],
              color: data['color'],
              defaultSubcategory:
                  DefaultSubcategory.values[data['defaultSubcategory']],
            ));
          }
        }
      }
    } catch (e) {
      return [];
    }
    return subcategoriesList;
  }

  Future copyCategory(Category category) async {
    try {
      DocumentReference newCategoryRef = await categories.add({
        'id': '',
        'name': '${category.name}(1)',
        'color': category.color,
      });

      try {
        QuerySnapshot snapshot =
            await categories.doc(category.id).collection('subcategories').get();
        if (snapshot.docs.isNotEmpty) {
          for (QueryDocumentSnapshot doc in snapshot.docs) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              DocumentReference newSubcategoryRef =
                  await newCategoryRef.collection('subcategories').add({
                'id': '',
                'name': data['name'],
                'color': data['color'],
                'defaultSubcategory': data['defaultSubcategory'],
              });
              try {
                QuerySnapshot snapshotItems = await categories
                    .doc(category.id)
                    .collection('subcategories')
                    .doc(doc.id)
                    .collection('items')
                    .get();
                if (snapshotItems.docs.isNotEmpty) {
                  for (QueryDocumentSnapshot docItem in snapshotItems.docs) {
                    Map<String, dynamic>? dataItem =
                        docItem.data() as Map<String, dynamic>?;
                    if (dataItem != null) {
                      await newSubcategoryRef.collection('items').add({
                        'id': '',
                        'name': dataItem['name'],
                        'expirationDate': dataItem['expirationDate'],
                        'quantity': dataItem['quantity'],
                        'size': dataItem['size'],
                        'notes': dataItem['notes'],
                      });
                    }
                  }
                }
              } catch (e) {
                categories.doc(newCategoryRef.id).delete();
                return false;
              }
            }
          }
        }
      } catch (e) {
        categories.doc(newCategoryRef.id).delete();
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
    return true;
  }

  Future updateCategory(Category category) async {
    return await categories.doc(category.id).set(category.toMap());
  }

  Future deleteCategory(String id) async {
    return await categories.doc(id).delete();
  }
}
