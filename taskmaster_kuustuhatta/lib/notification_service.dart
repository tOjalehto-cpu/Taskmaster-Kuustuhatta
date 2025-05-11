import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Alustaa ilmoituspalvelun
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Näyttää push-ilmoituksen
  static Future<void> showNotification(
    int id,
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_priority_channel', // Kanavan ID
          'Korkean prioriteetin tehtävät', // Kanavan nimi
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id, // Ilmoituksen ID
      title, // Otsikko
      body, // Viesti
      platformChannelSpecifics,
    );
  }
}
