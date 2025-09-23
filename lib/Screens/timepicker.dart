import 'package:flutter/material.dart';
class AlarmSetPage extends StatefulWidget {
  @override
  _AlarmSetPageState createState() => _AlarmSetPageState();

}

class _AlarmSetPageState extends State<AlarmSetPage> {
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async
  {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null)
      {

        setState(()
      {

        _selectedTime = picked;

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Alarm")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickTime,
              child: Text("Pick Alarm Time"),
            ),
            SizedBox(height: 20),
            Text(
              _selectedTime == null
                  ? "No Time Selected"
                  : "Selected: ${_selectedTime!.format(context)}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedTime != null) {
                  Navigator.pop(context, _selectedTime);
                  // return time back to HomePage
                }
              },
              child: Text("Save Alarm"),
            ),
          ],
        ),
      ),
    );
  }
}
