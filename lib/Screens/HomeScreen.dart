import 'dart:convert';
import 'package:alarm_clock_app/App_Utils/apputils.dart';
import 'package:alarm_clock_app/Screens/Alarmset.dart';
import 'package:alarm_clock_app/Screens/BedWakeSelector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../App_Utils/timeutils.dart';
import '../Notification.dart';
import '../models/alarm.dart';
import '../models/dailyrotiune.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Alarm> alarms = [];
  List<bool> switches = [];
  Dailyrotiune? routine;

  DateTime _todayWith(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Future<void> _loadRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('daily_routine');
    if (jsonString != null) {
      setState(() {
        routine = Dailyrotiune.fromJson(
            jsonDecode(jsonString) as Map<String, dynamic>);
      });
    }
  }

  Future<void> _saveRoutine(Dailyrotiune r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_routine', jsonEncode(r.toJson()));
  }

  @override
  void initState() {
    super.initState();
    _loadRoutine();
    loadAlarms();
  }

  void loadAlarms() async {
    final storedAlarms = await AppUtils.GetAlarm();
    setState(() {
      storedAlarms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      alarms = storedAlarms;
    });
  }

  void showRepeatDaysDialog(BuildContext context, int index) {
    final alarm = alarms[index];
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    List<int> selectedDays = List.from(alarm.repeatDays);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Repeated Days"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Wrap(
                spacing: 8,
                children: List.generate(days.length, (i) {
                  final dayNumber = i + 1;
                  final isSelected = selectedDays.contains(dayNumber);
                  return ChoiceChip(
                    label: Text(days[i]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedDays.add(dayNumber)
                            : selectedDays.remove(dayNumber);
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () async {
                setState(() => alarm.repeatDays = selectedDays);
                await AppUtils.SaveAlarm(alarms);
                await ShowAlarmNotification(
                    alarm.id, alarm.dateTime, alarm.description ?? "Alarm");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final wakeTime =
    routine == null ? null : _todayWith(routine!.wakeHour, routine!.wakeMinute);
    final sleepTime =
    routine == null ? null : _todayWith(routine!.sleepHour, routine!.sleepMinute);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Alarm Clock", style: TextStyle(color: Colors.yellow)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.yellow),
            onPressed: () async {
              final newAlarm = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Alarmset()),
              );
              if (newAlarm is Alarm) {
                setState(() {
                  alarms.add(newAlarm.copyWith(createdAt: DateTime.now()));
                  alarms.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  switches.add(false);
                });
                await AppUtils.SaveAlarm(alarms);
                await ShowAlarmNotification(
                    newAlarm.id, newAlarm.dateTime, newAlarm.description ?? '');
              }

            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Daily Routine Tile
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              tileColor: Colors.white24,
              minTileHeight: 100,
              trailing: Switch(
                value: routine?.enabled ?? false,
                activeColor: Colors.yellow,
                onChanged: (bool value) async {
                  if (routine == null) return;
                  setState(() {
                    routine = routine!.copyWith(enabled: value);
                  });
                  await _saveRoutine(routine!);
                },
              ),
              subtitle: routine != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(wakeTime!),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.sunny, color: Colors.yellow),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(sleepTime!),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.bedtime, color: Colors.yellow),
                    ],
                  ),
                ],
              )
                  : const Text("No times selected",
                  style: TextStyle(color: Colors.white38)),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BedWakeSelector()),
                );
                if (result is Dailyrotiune) {
                  setState(() => routine = result);
                  await _saveRoutine(result);
                }
              },
            ),
          ),

          // Alarms list
          Expanded(
            child: ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Dismissible(
                  key: ValueKey(alarm.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    setState(() => alarms.removeAt(index));
                    await CancelAlarm(alarm.id);
                    await AppUtils.SaveAlarm(alarms);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text("Alarm deleted",
                            style: TextStyle(color: Colors.black)),
                        backgroundColor: Colors.yellow,
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final TimeOfDay? newTime = await pickTime(context);
                      if (newTime != null) {
                        final updatedDateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          newTime.hour,
                          newTime.minute,
                        );
                        final oldId = alarms[index].id;
                        setState(() {
                          alarms[index] = alarms[index].copyWith(
                            dateTime: updatedDateTime,
                            createdAt: DateTime.now(), // keep top position
                          );
                        });
                        await AppUtils.SaveAlarm(alarms);
                        await CancelAlarm(oldId);
                        await ShowAlarmNotification(
                            oldId,
                            updatedDateTime,
                            alarms[index].description ?? "Alarm");
                      }
                    },
                    onLongPress: () => showRepeatDaysDialog(context, index),
                    child: ListTile(
                      isThreeLine: true,
                      tileColor: Colors.black,
                      leading: const Icon(Icons.alarm, color: Colors.white),
                      title: Text(
                        DateFormat('hh:mm a').format(alarm.dateTime),
                        style:
                        const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      subtitle: Text(
                        alarm.description ?? "",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Switch(
                        value: alarm.enabled,
                        activeColor: Colors.yellow,
                        onChanged: (bool value) async {
                          setState(() {
                            alarm.enabled = value;
                          });
                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text("Alarm on",
                                      style: TextStyle(color: Colors.black)),
                                  backgroundColor: Colors.yellow,
                                ));
                          } else {
                            await CancelAlarm(alarm.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text("Alarm off",
                                      style: TextStyle(color: Colors.black)),
                                  backgroundColor: Colors.yellow,
                                ));
                          }
                          await AppUtils.SaveAlarm(alarms);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
