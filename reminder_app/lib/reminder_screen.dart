import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _activities = [
    'Wake up', 'Go to gym', 'Breakfast', 'Meetings', 'Lunch', 'Quick nap', 'Go to library', 'Dinner', 'Go to sleep'
  ];

  String? _selectedDay;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedActivity;

  @override
  void initState() {
    super.initState();
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(),
    );
    _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification() async {
    final now = DateTime.now();
    final scheduleDate = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    if (scheduleDate.isBefore(now)) {
      scheduleDate.add(Duration(days: 1));
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: IOSNotificationDetails(),
    );

    await _notificationsPlugin.schedule(
      0,
      'Reminder',
      _selectedActivity,
      scheduleDate,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Day'),
              items: _days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value;
                });
              },
              value: _selectedDay,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null && time != _selectedTime) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              child: Text('Select Time: ${_selectedTime.format(context)}'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Activity'),
              items: _activities.map((activity) {
                return DropdownMenuItem(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivity = value;
                });
              },
              value: _selectedActivity,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedDay != null && _selectedActivity != null
                  ? () {
                      _scheduleNotification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reminder set for $_selectedActivity')),
                      );
                    }
                  : null,
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
