import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../screens/auth/login.dart';
import '../services/auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          return snapshot.hasData ? HomeScreen() : const LoginScreen();
        });
  }
}
