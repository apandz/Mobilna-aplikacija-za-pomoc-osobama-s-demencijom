import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/global_variables.dart';
import '../models/subcategory.dart';
import 'auth.dart';

class SubcategoryService {
  late final CollectionReference subcategories;

  SubcategoryService(String categoryId) {
    subcategories = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories');
  }

  Future getSubcategories() async {
    List<Subcategory> subcategoriesList = [];
    try {
      QuerySnapshot snapshot = await subcategories.get();
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

  Future addSubcategory(Subcategory subcategory) async {
    try {
      await subcategories.add(subcategory.toMap());
    } catch (e) {
      return false;
    }
    return true;
  }

  Future copySubcategory(
      Subcategory subcategory, SubcategoryService subcategoryService) async {
    try {
      DocumentReference newSubcategoryRef =
          await subcategories.add(subcategory.toMap());
      try {
        QuerySnapshot snapshotItems = await subcategoryService.subcategories
            .doc(subcategory.id)
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
        subcategories.doc(newSubcategoryRef.id).delete();
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
    return true;
  }

  Future updateSubcategory(Subcategory subcategory) async {
    return await subcategories.doc(subcategory.id).set(subcategory.toMap());
  }

  Future deleteSubcategory(String id) async {
    return await subcategories.doc(id).delete();
  }
}
