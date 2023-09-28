import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth.dart';

class UserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> saveToken(String? fCMToken) async {
    String id = '';
    final currentUser = Auth().currentUser;
    if (currentUser != null) {
      id = currentUser.uid;
      DocumentReference user = users.doc(id);
      user.set({'token': fCMToken}, SetOptions(merge: true));
    }
  }
}
