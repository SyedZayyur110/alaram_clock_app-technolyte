import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../Notification.dart';

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({super.key});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    startRingtone();
  }

  void startRingtone() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('sounds/sounds.wav'));
  }

  void stopRingtone() async {
    await player.stop();
  }
  snoozeFiveMinutes() async {
    await player.stop();                 ////// stop the looping sound////////
    final newTime = DateTime.now().add(const Duration(minutes: 5));
    await ShowAlarmNotification(          ////// reusing the same function///////
      DateTime.now().millisecondsSinceEpoch ~/ 1000, /////// unique id///////
      newTime,
      "5 minutes up",
    );
    Navigator.pop(context);
  }


  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Alarm Ringing!",
                style: TextStyle(color: Colors.white, fontSize: 32)),
            Image.asset("assets/alarm.png", height: 200, width: 150),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, fixedSize: const Size(150, 60)),
                  onPressed: () {
                    stopRingtone();
                    Navigator.pop(context);
                  },
                  child: const Text("Stop", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, fixedSize: const Size(150, 60)),
                  onPressed: () {
                    snoozeFiveMinutes();
                  },
                  child: const Text("Snooze 5 min",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
