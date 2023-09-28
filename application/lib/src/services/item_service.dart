import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../api/firebase_api.dart';
import '../models/item.dart';
import '../models/subcategory.dart';
import '../utils/global_variables.dart';
import 'auth.dart';

class ItemService {
  late final CollectionReference items;
  late final String categoryId;
  late final String subcategoryId;

  ItemService(this.categoryId, this.subcategoryId) {
    items = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('items');
  }

  Future getItems() async {
    List<Item> itemsList = [];
    try {
      QuerySnapshot snapshot = await items.get();
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            itemsList.add(Item(
              id: doc.id,
              name: data['name'],
              expirationDate: data['expirationDate'],
              quantity: data['quantity'],
              size: data['size'],
              notes: data['notes'],
            ));
          }
        }
      }
    } catch (e) {
      return [];
    }
    return itemsList;
  }

  Future getItem(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await items.doc(id).get() as DocumentSnapshot<Map<String, dynamic>>;
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;

        return Item(
          id: snapshot.id,
          name: data['name'],
          expirationDate: data['expirationDate'],
          quantity: data['quantity'],
          size: data['size'],
          notes: data['notes'],
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void addNotification(
      String itemId, Item item, dynamic data, String body, DateTime time) {
    FirebaseFirestore.instance.collection('notification').add({
      'itemId': itemId,
      'title': data['categoryName'],
      'body': item.name + body,
      'token': FirebaseApi.fCMToken,
      'data': data,
      'scheduledTime': time,
      'sent': false,
      'cancel': false,
    });
  }

  Future addItem(Item item, String categoryName, String subcategoryName,
      String newSubcategoryId,
      {String body = 'Expiring soon'}) async {
    try {
      await items.add(item.toMap()).then((value) async {
        DocumentReference subcategory = FirebaseFirestore.instance
            .collection('users')
            .doc(Auth().currentUser!.uid)
            .collection('categories')
            .doc(categoryId)
            .collection('subcategories')
            .doc(newSubcategoryId);
        DocumentSnapshot snapshot = await subcategory.get();
        if (snapshot.exists) {
          DefaultSubcategory defaultSubcategory =
              (snapshot.data() as Subcategory).defaultSubcategory;

          if (defaultSubcategory != DefaultSubcategory.toBuy &&
              item.expirationDate != null) {
            DateTime time =
                DateFormat('dd/MM/yyyy').parse(item.expirationDate!);
            time = DateTime(time.year, time.month, time.day, 14);
            if (time.difference(DateTime.now()).inDays > 7) {
              addNotification(
                value.id,
                item,
                {
                  'categoryId': categoryId,
                  'categoryName': categoryName,
                  'subcategoryId': newSubcategoryId,
                  'subcategoryName': subcategoryName,
                  'defaultSubcategory': defaultSubcategory.index.toString(),
                },
                body,
                time.subtract(
                  const Duration(days: 7),
                ),
              );
            }
            if (time.difference(DateTime.now()).inDays > 3) {
              addNotification(
                value.id,
                item,
                {
                  'categoryId': categoryId,
                  'categoryName': categoryName,
                  'subcategoryId': newSubcategoryId,
                  'subcategoryName': subcategoryName,
                  'defaultSubcategory': defaultSubcategory.index.toString(),
                },
                body,
                time.subtract(
                  const Duration(days: 3),
                ),
              );
            }
            if (time.difference(DateTime.now()).inDays > 1) {
              addNotification(
                value.id,
                item,
                {
                  'categoryId': categoryId,
                  'categoryName': categoryName,
                  'subcategoryId': newSubcategoryId,
                  'subcategoryName': subcategoryName,
                  'defaultSubcategory': defaultSubcategory.index.toString(),
                },
                body,
                time.subtract(
                  const Duration(days: 1),
                ),
              );
            }
          }
        }
      });
    } catch (e) {
      return false;
    }
    return true;
  }

  Future addItemInDefaultSubcategory(
      String categoryId,
      Item item,
      String categoryName,
      String subcategoryName,
      DefaultSubcategory defaultSubcategory,
      {String body = 'Expiring soon'}) async {
    try {
      CollectionReference subcategories = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().currentUser!.uid)
          .collection('categories')
          .doc(categoryId)
          .collection('subcategories');
      String subcategoryId = '';
      int equalTo = defaultSubcategory == DefaultSubcategory.toBuy ? 2 : 1;
      QuerySnapshot snapshot = await subcategories
          .where('defaultSubcategory', isEqualTo: equalTo)
          .get();
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            subcategoryId = doc.id;
          }
        }
      }
      await subcategories
          .doc(subcategoryId)
          .collection('items')
          .add(defaultSubcategory == DefaultSubcategory.toBuy
              ? item.toMap()
              : Item(
                  id: item.id,
                  name: item.name,
                  quantity: item.quantity,
                  size: item.size,
                  notes: item.notes,
                ).toMap())
          .then((value) {
        if (defaultSubcategory != DefaultSubcategory.toBuy &&
            item.expirationDate != null) {
          DateTime time = DateFormat('dd/MM/yyyy').parse(item.expirationDate!);
          time = DateTime(time.year, time.month, time.day, 14);
          if (time.difference(DateTime.now()).inDays > 7) {
            addNotification(
              value.id,
              item,
              {
                'categoryId': categoryId,
                'categoryName': categoryName,
                'subcategoryId': subcategoryId,
                'subcategoryName': subcategoryName,
                'defaultSubcategory': defaultSubcategory.index.toString(),
              },
              body,
              time.subtract(
                const Duration(days: 7),
              ),
            );
          }
          if (time.difference(DateTime.now()).inDays > 3) {
            addNotification(
              value.id,
              item,
              {
                'categoryId': categoryId,
                'categoryName': categoryName,
                'subcategoryId': subcategoryId,
                'subcategoryName': subcategoryName,
                'defaultSubcategory': defaultSubcategory.index.toString(),
              },
              body,
              time.subtract(
                const Duration(days: 3),
              ),
            );
          }
          if (time.difference(DateTime.now()).inDays > 1) {
            addNotification(
              value.id,
              item,
              {
                'categoryId': categoryId,
                'categoryName': categoryName,
                'subcategoryId': subcategoryId,
                'subcategoryName': subcategoryName,
                'defaultSubcategory': defaultSubcategory.index.toString(),
              },
              body,
              time.subtract(
                const Duration(days: 1),
              ),
            );
          }
        }
      });
    } catch (e) {
      return false;
    }
    return true;
  }

  Future updateItem(Item item, {bool expirationDateChanged = false}) async {
    return await items.doc(item.id).set(item.toMap()).then((_) async {
      if (expirationDateChanged) {
        DateTime? scheduledTime;
        if (item.expirationDate != null) {
          scheduledTime = DateFormat('dd/MM/yyyy').parse(item.expirationDate!);
        }
        CollectionReference notifications =
            FirebaseFirestore.instance.collection('notification');
        final notificationIds = [];
        QuerySnapshot snapshot = await notifications
            .where('token', isEqualTo: FirebaseApi.fCMToken)
            .where('itemId', isEqualTo: item.id)
            .get();
        if (snapshot.docs.isNotEmpty) {
          for (QueryDocumentSnapshot doc in snapshot.docs) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              notificationIds.add(doc.id);
            }
          }
        }
        if (scheduledTime != null) {
          scheduledTime = DateTime(
              scheduledTime.year, scheduledTime.month, scheduledTime.day, 14);
        }
        int difference = 7;
        for (var notificationId in notificationIds) {
          if (scheduledTime != null) {
            if (scheduledTime.difference(DateTime.now()).inDays > difference) {
              notifications.doc(notificationId).update({
                'scheduledTime': scheduledTime.subtract(
                  Duration(days: difference),
                ),
              });
              if (difference == 3) {
                difference = 1;
              }
              if (difference == 7) {
                difference = 3;
              }
            }
          } else {
            notifications.doc(notificationId).update({
              'scheduledTime': scheduledTime,
            });
          }
        }
      }
    });
  }

  Future deleteItem(String id) async {
    return await items.doc(id).delete().then((_) async {
      CollectionReference notifications =
          FirebaseFirestore.instance.collection('notification');
      final notificationIds = [];
      QuerySnapshot snapshot = await notifications
          .where('token', isEqualTo: FirebaseApi.fCMToken)
          .where('itemId', isEqualTo: id)
          .get();
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            notificationIds.add(doc.id);
          }
        }
      }
      for (var notificationId in notificationIds) {
        notifications.doc(notificationId).delete();
      }
    });
  }
}
