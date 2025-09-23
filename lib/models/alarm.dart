import 'package:flutter/material.dart';

class Alarm {
  int id;
  DateTime dateTime;
  TimeOfDay? time;
  String? description;
  List<int> repeatDays;
  bool enabled;

  Alarm({
    required this.id,
    required this.dateTime,
    this.description,
    this.enabled = true,
    this.repeatDays= const [],
    this.time,
  });

  /////// Method to convert json String to object ///////////
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      description: json['description'],
      enabled: json['enabled'] ?? true,
      repeatDays: List<int>.from(json['repeatDays'] ?? []),
      time: json['time'] != null
          ? TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      )
          : null,
    );
  }

  ////// Method to convert object to json String ///////////
  Map<String, dynamic> toJson() {
    return {
       'id':id,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'enabled': enabled,
      'repeatDays': repeatDays,
      if (time != null)
        'time': {
          'hour': time!.hour,
          'minute': time!.minute,
        },
    };
  }

  Alarm copyWith({
    int ? id,
    DateTime? dateTime,
    String? description,
    bool? enabled,
    List<int>? repeatDays,
    TimeOfDay? time,
  }) {
    return Alarm(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      repeatDays: repeatDays??this.repeatDays,
      time: time ?? this.time,
    );
  }
}
