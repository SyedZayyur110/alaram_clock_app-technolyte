import 'package:alarm_clock_app/Screens/HomeScreen.dart';
import 'package:alarm_clock_app/models/alarm.dart';
import 'package:alarm_clock_app/widgets/customfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../App_Utils/timeutils.dart';
class Alarmset extends StatefulWidget {
  const Alarmset({super.key});

  @override
  State<Alarmset> createState() => _AlarmsetState();

}

class _AlarmsetState extends State<Alarmset> {
  final U = GlobalKey<FormState>();
  TimeOfDay? selectedTime;
  TimeOfDay? newAlarm;
  List<int> selectedDays = [];
  @override
    Widget build(BuildContext context) {
    final msgcntrl = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actionsPadding: EdgeInsets.fromLTRB(0, 0, 360, 0),
        actions: [
          IconButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> Homescreen())
          );
        },
       icon: Icon(Icons.arrow_back,color: Colors.yellow,)),
        ],
      ),
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              selectedTime == null
                  ? "No Time Selected"
                  : "Selected: ${selectedTime!.format(context)}",
              style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow,),
              child: Text("Select Time",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
              onPressed:() async {
                final time = await pickTime(context);
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomField(
              label: "Alarm Name",
              controller: msgcntrl,

            ),
          ),
          Text(
            " Select Days To Repeat Alarm",style: TextStyle(color: Colors.yellow,
          fontSize: 20, fontWeight: FontWeight.bold),

          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final dayLabels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
                final dayNumber = i + 1; /////DateTime weekday: 1=Mon,7=Sun///
                final isSelected = selectedDays.contains(dayNumber);
                return ChoiceChip(
                  label: Text(dayLabels[i]),
                  selected: isSelected,
                  selectedColor: Colors.yellow,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedDays.add(dayNumber);
                      } else {
                        selectedDays.remove(dayNumber);
                      }
                    });
                  },
                );
              }),
            ),
          ),

          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow,fixedSize:  Size.fromWidth(300)),
              onPressed:(){

                final selectedtime = this.selectedTime;
                if (selectedtime!= null)
                {
                  final now = DateTime.now();
                  final dtime =DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedtime.hour,
                  selectedtime.minute,
                );
                  Navigator.pop(context,
                    Alarm
                    (
                      id: now.millisecondsSinceEpoch % 2147483647,
                      dateTime: dtime,
                      description: msgcntrl.text.toString(),
                      enabled: true,
                        repeatDays: selectedDays,
                    ),
                    );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.yellow,
                      content: Text(
                        "Alarm set for ${selectedTime?.format(context)} "
                            "${selectedDays.isEmpty ? '' : 'on ${selectedDays.length} day(s)'}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }
              },
              child: Text("Save Alarm",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
    );
  }
}
