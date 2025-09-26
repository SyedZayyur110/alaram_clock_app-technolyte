import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Notification.dart';
import '../models/dailyrotiune.dart';
import 'HomeScreen.dart';

class BedWakeSelector extends StatefulWidget {
  @override
  State<BedWakeSelector> createState() => _BedWakeSelectorState();
}

class _BedWakeSelectorState extends State<BedWakeSelector> {
  double startAngle = math.pi * 1.5; // 12 o'clock
  double endAngle = math.pi / 2; // 6 o'clock
  final double radius = 140;
  DateTime selectedBed = DateTime(0, 0, 0, 0, 0);
  DateTime selectedWake = DateTime(0, 0, 0, 0, 0);
  bool? draggingStart;
  double? _lastDragAngle;

  @override
  void initState()
  {
    super.initState();
    _loadRoutine();
  }
  Future<void> _loadRoutine() async
  {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('daily_routine');
    if (json != null) {
      final saved = Dailyrotiune.fromJson(jsonDecode(json));
      setState(() {

        selectedBed  = DateTime(0, 0, 0, saved.sleepHour, saved.sleepMinute);
        selectedWake = DateTime(0, 0, 0, saved.wakeHour, saved.wakeMinute);

        startAngle = _angleFromTime(saved.sleepHour, saved.sleepMinute);
        endAngle   = _angleFromTime(saved.wakeHour,  saved.wakeMinute);
      });
    }
  }
  DateTime _nextOccurrence(int hour, int minute)
  {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

                           //////helpers////////
  double _angleFromTime(int h, int m) {
    final minutes = h * 60 + m;
    return ((minutes / (24 * 60)) * 2 * math.pi - math.pi / 2) % (2 * math.pi);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Set Your Daily Routine"),
        centerTitle: true,
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
            color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final bed  = _timeFromAngle(startAngle);
                  final wake = _timeFromAngle(endAngle);

                  final routine = Dailyrotiune(
                    sleepHour: bed.hour,
                    sleepMinute: bed.minute,
                    wakeHour: wake.hour,
                    wakeMinute: wake.minute,
                    enabled: true,
                  );

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('daily_routine', jsonEncode(routine.toJson()));

                  /////Cancel any previous alarms//////
                  await CancelAlarm(100); // Sleep notification
                  await CancelAlarm(101); // Wake notification
                  await CancelAlarm(102);
                  await CancelAlarm(103);
                  await CancelAlarm(104);
                  await CancelAlarm(105);

                  //////Schedule new alarms with updated times////
                  final sleepTime = _nextOccurrence(routine.sleepHour, routine.sleepMinute);
                  final wakeTime  = _nextOccurrence(routine.wakeHour,  routine.wakeMinute);

                  await ShowAlarmNotification(100, sleepTime, 'Time to sleep 😴');
                  await ShowAlarmNotification(101, wakeTime, 'Time to wake up ⏰');
                  await ShowAlarmNotification(102, wakeTime.add(const Duration(minutes: 15)),
                      'Drink a glass of water 💧');
                  await ShowAlarmNotification(103, wakeTime.add(const Duration(hours: 1)),
                      'Have your breakfast 🍳');
                  final lunchTime = wakeTime.add(const Duration(hours: 5));
                  await ShowAlarmNotification(104, lunchTime,
                      'Time for lunch 🥗');
                  await ShowAlarmNotification(105, lunchTime.add(const Duration(hours: 5)),
                      'Time for dinner 🍽️');
                  Navigator.pop(context, routine);
                },

                child: const Text("Save",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      body:
      Column(
        children: [
          const SizedBox(height: 80),
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) {
              draggingStart = null;
              _lastDragAngle = null;
            },
            child: CustomPaint(
              size: Size(radius * 2 + 40, radius * 2 + 40),
              painter: _RingPainter(startAngle, endAngle),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            [
              const Icon(Icons.bedtime, color: Colors.yellow),
              const SizedBox(width: 8),
              Text(_formatTime(startAngle),
                  style: const TextStyle(fontSize: 28, color: Colors.yellow)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sunny, color: Colors.yellow),
              const SizedBox(width: 8),
              Text(_formatTime(endAngle),
                  style: const TextStyle(fontSize: 28, color: Colors.yellow)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Sleep time: ${_sleepHours()} hrs",
            style: const TextStyle(color: Colors.yellow),
          ),

        ],
      ),
    );
  }

  //////////Gesture handlers using delta updates/////////////////////
  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final center = box.size.center(Offset.zero);
    final local = box.globalToLocal(details.globalPosition);
    final angle = _angleFromCenter(center, local);

    ///////choose nearest knob///////////////////
    final dStart = _circularDistance(angle, startAngle);
    final dEnd = _circularDistance(angle, endAngle);
    draggingStart = dStart < dEnd;
    _lastDragAngle = angle;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lastDragAngle == null || draggingStart == null) return;
    final box = context.findRenderObject() as RenderBox;
    final center = box.size.center(Offset.zero);
    final local = box.globalToLocal(details.globalPosition);
    final angle = _angleFromCenter(center, local);

    /////computed signed smallest delta between last and current pointer angles//////

    final delta = _angleDelta(_lastDragAngle!, angle);
    _lastDragAngle = angle;

    setState(() {
      if (draggingStart!) {
        startAngle = _normalize(startAngle + delta);
      } else {
        endAngle = _normalize(endAngle + delta);
      }
    });
  }

  ////////////angle helpers///////////////////
  double _angleFromCenter(Offset center, Offset point)
  {
    final a = math.atan2(point.dy - center.dy, point.dx - center.dx);
    return _normalize(a);
  }

  double _normalize(double a)
  {
    // wraping th4  angle to [0, 2π)
    while (a < 0) a += 2 * math.pi;
    while (a >= 2 * math.pi) a -= 2 * math.pi;
    return a;
  }

  double _angleDelta(double from, double to)
  {
    double diff = to - from;
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return diff;
  }
  TimeOfDay _timeFromAngle(double angle)
  {
    final totalMinutes =
        ((_normalize(angle) + math.pi / 2) % (2 * math.pi)) /
            (2 * math.pi) * 24 * 60;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes.round() % 60;
    return TimeOfDay(hour: h, minute: m);
  }



  double _circularDistance(double a, double b)
  {
    final diff = (a - b).abs();
    return diff > math.pi ? 2 * math.pi - diff : diff;
  }

  String _formatTime(double angle)
  {
    final mins = ((_normalize(angle) + math.pi / 2) % (2 * math.pi)) /
        (2 * math.pi) * 24 * 60;
    final h = mins ~/ 60;
    final m = mins.round() % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return "${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period";
  }

  String _sleepHours()
  {
    final startMins = ((_normalize(startAngle) + math.pi / 2) % (2 * math.pi)) /
        (2 * math.pi) * 24 * 60;
    final endMins = ((_normalize(endAngle) + math.pi / 2) % (2 * math.pi)) /
        (2 * math.pi) * 24 * 60;
    double diff = endMins - startMins;
    if (diff < 0) diff += 24 * 60;
    return (diff / 60).toStringAsFixed(1);
  }
}

///////////Painter (shows colorful ring, inner ticks, numbers 0/6/12/18)//////////
class _RingPainter extends CustomPainter
{
  final double start;
  final double end;
  _RingPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;

    ////// colorful outer ring (base + selected arc)//////////////
    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final selPaint = Paint()
      ..shader = SweepGradient(colors: [Colors.orange, Colors.amber])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius, basePaint);

    final sweep = (end - start) % (2 * math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep <= 0 ? sweep + 2 * math.pi : sweep,
      false,
      selPaint,
    );

    //////////////// inner tick marks ////////////////////
    final tickPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.5;

    for (int i = 0; i < 60; i++) {
      final angle = i * math.pi / 30; // 6° steps
      final isHour = i % 5 == 0;
      final inner = radius - 14;
      final outer = isHour ? radius - 4 : radius - 8;

      final p1 = Offset(center.dx + inner * math.cos(angle - math.pi / 2),
          center.dy + inner * math.sin(angle - math.pi / 2));
      final p2 = Offset(center.dx + outer * math.cos(angle - math.pi / 2),
          center.dy + outer * math.sin(angle - math.pi / 2));
      canvas.drawLine(p1, p2, tickPaint);
    }

    //////// labels: 0 (top), 6 (right), 12 (bottom), 18 (left)/////////////////
    final labels = ['0', '6', '12', '18'];
    final textStyle = const TextStyle(color: Colors.white, fontSize: 16);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + i * math.pi / 2;
      tp.text = TextSpan(text: labels[i], style: textStyle);
      tp.layout();
      final pos = Offset(center.dx + (radius - 28) * math.cos(angle),
          center.dy + (radius - 28) * math.sin(angle));
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    /////////// knobs////////////////////
    _drawKnob(canvas, center, radius, start);
    _drawKnob(canvas, center, radius, end);
  }

  void _drawKnob(Canvas canvas, Offset c, double r, double angle) {
    final pos = Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
    canvas.drawCircle(pos, 16, Paint()..color = Colors.orange);
    // optional outline
    canvas.drawCircle(
        pos,
        20,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withOpacity(0.12));
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.start != start || old.end != end;
}
