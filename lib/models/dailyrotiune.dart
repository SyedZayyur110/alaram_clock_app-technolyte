class Dailyrotiune {
  final int sleepHour;
  final int sleepMinute;
  final int wakeHour;
  final int wakeMinute;
  final bool enabled;

  Dailyrotiune({
    required this.sleepHour,
    required this.sleepMinute,
    required this.wakeHour,
    required this.wakeMinute,
    this.enabled = false,
  });

  Dailyrotiune copyWith({
    int? sleepHour,
    int? sleepMinute,
    int? wakeHour,
    int? wakeMinute,
    bool? enabled,
  })

  {
    return Dailyrotiune(
      sleepHour: sleepHour ?? this.sleepHour,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      wakeHour: wakeHour ?? this.wakeHour,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'sleepHour': sleepHour,
    'sleepMinute': sleepMinute,
    'wakeHour': wakeHour,
    'wakeMinute': wakeMinute,
    'enabled': enabled,
  };

  factory Dailyrotiune.fromJson(Map<String, dynamic> json) => Dailyrotiune(
    sleepHour: json['sleepHour'],
    sleepMinute: json['sleepMinute'],
    wakeHour: json['wakeHour'],
    wakeMinute: json['wakeMinute'],
    enabled: json['enabled'] ?? false,
  );
}
