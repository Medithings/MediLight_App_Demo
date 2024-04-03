
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  LocalNotification._();

  static FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

  static init() async {

    AndroidInitializationSettings android = const AndroidInitializationSettings("@mipmap/ic_launcher");

    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    InitializationSettings settings = InitializationSettings(android: android, iOS: ios);

    await flnp.initialize(settings);
  }

  static requestNotificationPermission(){
    flnp.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> showNotification(String title, String body) async{
    const AndroidNotificationDetails and = AndroidNotificationDetails(
      "channelId",
      "channelName",
      channelDescription: "channel description",
      importance: Importance.max,
      priority: Priority.max,
      showWhen: false
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: and,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flnp.show(0, title, body, notificationDetails);
  }


}