import 'package:flutter/material.dart';

class Alarm {
  int id;
  DateTime dateTime;
  DateTime createdAt;
  TimeOfDay? time;
  String? description;
  List<int> repeatDays;
  bool enabled;

  Alarm({
    required this.id,
    required this.dateTime,
    required this.createdAt,
    this.description,
    this.enabled = true,
    this.repeatDays = const [],
    this.time,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      createdAt: DateTime.parse(json['createdAt']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
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
    int? id,
    DateTime? dateTime,
    DateTime? createdAt,
    String? description,
    bool? enabled,
    List<int>? repeatDays,
    TimeOfDay? time,
  }) {
    return Alarm(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      repeatDays: repeatDays ?? this.repeatDays,
      time: time ?? this.time,
    );
  }
}
