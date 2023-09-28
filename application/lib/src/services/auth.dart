import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/firebase_api.dart';
import 'user_service.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((_) {
      FirebaseApi firebaseApi = FirebaseApi();
      firebaseApi.saveToken();
    });
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((_) {
      FirebaseApi firebaseApi = FirebaseApi();
      firebaseApi.saveToken();
    });
  }

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential).then((_) {
      FirebaseApi firebaseApi = FirebaseApi();
      firebaseApi.saveToken();
    });
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    final credentials = EmailAuthProvider.credential(
        email: currentUser!.email!, password: oldPassword);

    String? errorMessage;

    await currentUser!.reauthenticateWithCredential(credentials).then((value) {
      currentUser!.updatePassword(newPassword).then((_) {}).catchError((error) {
        errorMessage = error.toString();
      });
    }).catchError((err) {
      errorMessage = err.toString();
    });
    return errorMessage;
  }

  Future<void> signOut() async {
    UserService userService = UserService();
    userService.saveToken(null);
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
