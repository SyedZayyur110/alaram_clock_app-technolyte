import 'package:flutter/material.dart';

Future<TimeOfDay?> pickTime(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    helpText: "Select Time for Your Alarm"
  );
  if (picked != null) {
    print("Picked Time: ${picked.format(context)}");
  }
  return picked;
}
