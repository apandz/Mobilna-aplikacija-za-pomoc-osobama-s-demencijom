import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';
import '../services/user_service.dart';
import '../utils/global_variables.dart';
import '../screens/home.dart';
import '../screens/items.dart';
import '../screens/list.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (BuildContext context) => HomeScreen(),
    ),
  );
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (BuildContext context) => ListScreen(
        categoryId: message.data['categoryId'],
        text: message.data['categoryName'],
      ),
    ),
  );

  DefaultSubcategory defaultSubcategory = DefaultSubcategory.not;
  if (int.parse(message.data['defaultSubcategory']) == 1) {
    defaultSubcategory = DefaultSubcategory.toBuy;
  }
  if (int.parse(message.data['defaultSubcategory']) == 2) {
    defaultSubcategory = DefaultSubcategory.storage;
  }

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (BuildContext context) => ItemsScreen(
        categoryName: message.data['categoryName'],
        categoryId: message.data['categoryId'],
        text: message.data['subcategoryName'],
        subcategoryId: message.data['subcategoryId'],
        defaultSubcategory: defaultSubcategory,
      ),
    ),
  );
}

class FirebaseApi {
  static String? fCMToken;
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.max,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    handleBackgroundMessage(message);
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) async {
        final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
        handleMessage(message);
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      AppleNotification? appleNotification = message.notification?.apple;
      if (notification == null) return;

      if (androidNotification != null || appleNotification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/bell',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: jsonEncode(message.toMap()),
        );
      }
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    await saveToken();
    initPushNotifications();
    initLocalNotifications();
  }

  Future saveToken() async {
    fCMToken = await _firebaseMessaging.getToken();
    UserService userService = UserService();
    userService.saveToken(fCMToken);
  }
}
