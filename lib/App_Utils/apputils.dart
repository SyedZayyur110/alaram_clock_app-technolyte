import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm.dart';
class AppUtils {
  static Future<void> SaveAlarm(List<Alarm> alarms,) async {
    final spref = await SharedPreferences.getInstance();
    List<String> alarmlist = alarms.map((a) => jsonEncode(a.toJson())).toList();
    await spref.setStringList("alarms", alarmlist);

  }

  static Future<List<Alarm>> GetAlarm() async {
    final spref = await SharedPreferences.getInstance();
    List<String>? alarmlist = spref.getStringList("alarms");
    if (alarmlist == null) return [];
    return alarmlist
        .map((a) => Alarm.fromJson(jsonDecode(a) as Map<String, dynamic>))
        .toList();
  }
}

