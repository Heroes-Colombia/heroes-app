import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

class CloudMessageService {
  CloudMessageService();

  final locator = GetIt.instance;

  //This method is used to check if the user has notificatios enabled for the app
  Future<bool> getNotificationsPermission() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    final settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  //This method is used to set init the local notifications for the app
  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await FlutterLocalNotificationsPlugin().initialize(initSettings);

    //This method is used to handle the notifications on foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      log("Message data received");
      log("data: ${message.data}");
      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          //All notifications will be shown in the same channel, the user in the app can change the topics to subscribe
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'heroes_app',
              'Todas las Notificaciones',
              importance: Importance.defaultImportance,
              colorized: true,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    });
  }

  /* 
     This method is used to change or update the user device notification token on each login. 
     We do this to ensure that the user will receive the notifications on the device that he is currently using.
     The device notification token changes when the user login from another device. Or on every reinstall of the app.
    */
  Future<void> handleDeviceNotificationToken(
    String? userNotificationToken,
    String usersCollection,
    String userUid,
  ) async {
    final localDeviceNotificationToken = await getNotificationToken();
    if (userNotificationToken == null) {
      //If the user doesn't have a device notification token, we save it
      await locator.get<FirestoreService>().editDocumentById(
        usersCollection,
        userUid,
        "uid",
        {"device_notification_token": localDeviceNotificationToken},
      );
    } else if (userNotificationToken != localDeviceNotificationToken) {
      //If the user login from another device, we update the device notification token
      await locator.get<FirestoreService>().editDocumentById(
        usersCollection,
        userUid,
        "uid",
        {"device_notification_token": localDeviceNotificationToken},
      );
    }
  }

  //This method is used to get the notification token for the current user device
  Future<String?> getNotificationToken() async {
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      return await firebaseMessaging.getToken();
    } catch (e) {
      // Handle the error
      log("Error getting notification token: $e");
      return null;
    }
  }

  //This method is used to subscribe the user to bussines or user channel
  Future<void> subscribeToTopic(String topic) async {
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      await firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Handle the error
      log("Error subscribing to topic: $e");
    }
  }

  //This method is used to unsubscribe the user to bussines or user channel
  Future<void> unsubscribeFromTopic(String topic) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
