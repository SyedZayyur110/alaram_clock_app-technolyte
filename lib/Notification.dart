import 'package:alarm_clock_app/models/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'Screens/AlarmRingingScreen.dart';
import 'main.dart';
import 'package:intl/intl.dart';
final flutterlocalNotificationPlugin = FlutterLocalNotificationsPlugin();
Future<void> initNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
  AndroidInitializationSettings('@mipmap/alarm_clock_icon');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: androidInitializationSettings);

  await flutterlocalNotificationPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const AlarmRingingScreen()),
      );
      final androidImplementation =
      flutterlocalNotificationPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (await androidImplementation?.areNotificationsEnabled() == false)
      {
        await androidImplementation?.requestExactAlarmsPermission();
        await androidImplementation?.requestFullScreenIntentPermission();
      }
    },
  );

  //////// Timezone setup important for zonedSchedule////////////
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
}

// Function to ring alarm when app is killed or closed///

Future<void> ShowAlarmNotification(int id , DateTime time, String Description
    ,{List<int> repeatDays = const []}) async {
  final now = DateTime.now();

  String formattedTime = DateFormat('hh:mm a').format(time);
  const AndroidNotificationDetails
    androidNotificationDetails =AndroidNotificationDetails(
      'Alarm_channel',
      'Alarms',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      //playSound: true,  // disable kiya ha ta k assest ka apna sound play ho
     ongoing: true,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    sound: RawResourceAndroidNotificationSound('sound'),
    enableVibration: true,
    enableLights: true,
  );
  const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
  await flutterlocalNotificationPlugin.zonedSchedule(
     id,
    'Hey its ${formattedTime}',
    Description,
    tz.TZDateTime.from(time, tz.local),
    notificationDetails,
    matchDateTimeComponents: DateTimeComponents.time,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void>CancelAlarm(int id)
async {
  //// cancel the notification with id value of zero////
  await flutterlocalNotificationPlugin.cancel(id);
}


