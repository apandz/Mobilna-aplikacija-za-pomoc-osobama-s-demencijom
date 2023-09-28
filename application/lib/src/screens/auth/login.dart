import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_text_field.dart';
import '../../services/auth.dart';
import '../../utils/global_variables.dart';
import '../../utils/utils.dart';
import '../home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? errorMessage = '';
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      errorMessage = '';
    } on FirebaseAuthException {
      setState(() {
        errorMessage =
            AppLocalizations.of(context)!.invalidCredentials;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await Auth().createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        errorMessage = '';
      } else {
        errorMessage = AppLocalizations.of(context)!.noMatchPasswordError;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = AppLocalizations.of(context)!.emailAlreadyInUse;
        } else if (e.code == 'weak-password') {
          errorMessage = AppLocalizations.of(context)!.weakPassword;
        } else {
          errorMessage = AppLocalizations.of(context)!.invalidCredentials;
        }
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await Auth().signInWithGoogle();
      errorMessage = '';
    } on FirebaseAuthException {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.invalidCredentials;
      });
    }
  }

  Future<bool> checkConnection() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.appBarBoxColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                GlobalVariables.logoImage,
                width: 80.0,
                height: 80.0,
              ),
              const SizedBox(
                height: 40.0,
              ),
              Text(
                isLogin
                    ? AppLocalizations.of(context)!.signIn
                    : AppLocalizations.of(context)!.signUp,
                style: GlobalVariables.textStyle1
                    .copyWith(color: GlobalVariables.fontColor, fontSize: 22.0),
              ),
              const SizedBox(
                height: 20.0,
              ),
              CustomTextField(
                label: AppLocalizations.of(context)!.email,
                controller: emailController,
                textFieldType: TextFieldType.email,
              ),
              CustomTextField(
                label: AppLocalizations.of(context)!.password,
                controller: passwordController,
                textFieldType: TextFieldType.password,
              ),
              isLogin
                  ? const SizedBox.shrink()
                  : CustomTextField(
                      label: AppLocalizations.of(context)!.confirmPassword,
                      controller: confirmPasswordController,
                      textFieldType: TextFieldType.password,
                    ),
              errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: GlobalVariables.textStyle2.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.normal,
                          fontSize: 13.0,
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 10.0,
                    ),
              CustomButton(
                onPressed: () {
                  checkConnection().then((value) {
                    if (value) {
                      (isLogin
                              ? signInWithEmailAndPassword()
                              : createUserWithEmailAndPassword())
                          .then((value) {
                        if (errorMessage == null || errorMessage!.isEmpty) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: ((context) => HomeScreen()),
                            ),
                          );
                        }
                      });
                    } else {
                      showSnackBar(
                          context, AppLocalizations.of(context)!.noInternet);
                    }
                  });
                },
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(width: 0.5),
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () {
                      checkConnection().then((value) {
                        if (value) {
                          signInWithGoogle().then((value) {
                            if (errorMessage == null || errorMessage!.isEmpty) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: ((context) => HomeScreen()),
                                ),
                              );
                            }
                          });
                        } else {
                          showSnackBar(context,
                              AppLocalizations.of(context)!.noInternet);
                        }
                      });
                    },
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Positioned(
                          left: 10.0,
                          top: 0.0,
                          bottom: 0.0,
                          child: SvgPicture.asset(
                            GlobalVariables.googleIcon,
                            width: GlobalVariables.iconSize,
                            height: GlobalVariables.iconSize,
                          ),
                        ),
                        Positioned(
                          child: Text(
                            isLogin
                                ? AppLocalizations.of(context)!.signInWithGoogle
                                : AppLocalizations.of(context)!
                                    .signUpWithGoogle,
                            style: GlobalVariables.textStyle2.copyWith(
                              color: GlobalVariables.fontColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                    errorMessage = '';
                  });
                },
                child: Text(
                  isLogin
                      ? AppLocalizations.of(context)!.createAnAccount
                      : AppLocalizations.of(context)!.alreadyHaveAnAccount,
                  style: GlobalVariables.textStyle2.copyWith(
                    color: GlobalVariables.textFieldColor2,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
