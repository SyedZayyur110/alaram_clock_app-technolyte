// // Notification.dart
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:intl/intl.dart';
// import 'dart:isolate';
// import 'dart:ui';
//
// import '../main.dart';
// import 'AlarmRingingScreen.dart';
//
// final FlutterLocalNotificationsPlugin notificationPlugin =
// FlutterLocalNotificationsPlugin();
//
// /// Initialize notifications and alarm manager
// Future<void> initNotifications() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   const androidInit = AndroidInitializationSettings('@mipmap/alarm_clock_icon');
//   const initSettings = InitializationSettings(android: androidInit);
//
//   await notificationPlugin.initialize(
//     initSettings,
//     onDidReceiveNotificationResponse: (NotificationResponse response) async {
//       navigatorKey.currentState?.push(
//         MaterialPageRoute(builder: (_) => const AlarmRingingScreen()),
//       );
//
//       final androidImplementation =
//       notificationPlugin.resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>();
//
//       if (await androidImplementation?.areNotificationsEnabled() == false) {
//         await androidImplementation?.requestNotificationsPermission();
//       }
//
//       if (await androidImplementation?.areNotificationsEnabled() == true) {
//         await androidImplementation?.requestExactAlarmsPermission();
//         await androidImplementation?.requestFullScreenIntentPermission();
//       }
//     },
//   );
//
//   await AndroidAlarmManager.initialize();
// }
//
// /// Callback triggered by Android alarm
// @pragma('vm:entry-point')
// void alarmCallback(int id, [dynamic params]) async {
//   Map<String, dynamic> mapParams = {};
//   if (params != null) mapParams = Map<String, dynamic>.from(params);
//
//   // Parse alarm time
//   String isoString = mapParams['alarmTime'] ?? DateTime.now().toIso8601String();
//   DateTime alarmTime = DateTime.parse(isoString);
//   String formattedTime = DateFormat('hh:mm a').format(alarmTime);
//
//   // Optional: custom description
//   String description = mapParams['description'] ?? 'It\'s time!';
//
//   final androidDetails = AndroidNotificationDetails(
//     'alarm_channel',
//     'Alarms',
//     channelDescription: 'Alarm notifications',
//     importance: Importance.max,
//     priority: Priority.high,
//     sound: const RawResourceAndroidNotificationSound('sound'),
//     playSound: true,
//     enableVibration: true,
//     ongoing: true,
//     fullScreenIntent: true,
//     audioAttributesUsage: AudioAttributesUsage.alarm,
//     additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT
//   );
//
//   await notificationPlugin.show(
//     id,
//     'Alarm at $formattedTime',
//     description,
//     NotificationDetails(android: androidDetails),
//   );
// }
//
// /// Schedule an exact alarm
// Future<void> scheduleExactAlarm(int id, DateTime when, {String? description}) async {
//   await AndroidAlarmManager.oneShotAt(
//     when,
//     id,
//     alarmCallback,
//     exact: true,
//     wakeup: true,
//     rescheduleOnReboot: true,
//     params: {
//       'alarmTime': when.toIso8601String(),
//       'description': description ?? 'It\'s time!',
//     },
//   );
// }
//
// /// Cancel alarm by id
// Future<void> cancelAlarm(int id) async {
//   await AndroidAlarmManager.cancel(id);
//   await notificationPlugin.cancel(id);
// }
