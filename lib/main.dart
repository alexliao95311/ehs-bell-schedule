import 'package:flutter/material.dart';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'notification_controller.dart';
import 'package:intl/intl.dart';  // Import the intl package


void main() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Basic notifications channel',
      defaultColor: Color(0xFF9D50DD),
      ledColor: Colors.white,
      channelGroupKey: "basic_channel_group"
    )
  ],
  channelGroups: [
    NotificationChannelGroup(
      channelGroupKey: 'basic_channel_group',
      channelGroupName: 'Basic Group',
    )
  ]);

  bool isAllowedToSendNotification = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(const BellScheduleApp());
}

class BellScheduleApp extends StatelessWidget {
  const BellScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EHS Bell Schedule',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade900,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentClass = '';
  String _currentTime = '';
  String _timeLeft = '';
  String _currentSchedule = '';
  bool notificationSent = false;
  Map<String, String> customClassNames = {
    'Period 0': 'Period 0',
    'Period 1': 'Period 1',
    'Period 2': 'Period 2',
    'Period 3': 'Period 3',
    'Period 4': 'Period 4',
    'Period 5': 'Period 5',
    'Period 6': 'Period 6',
    'Period 7': 'Period 7',
  };

  final Map<String, List<Map<String, String>>> schedules = {
    'Monday': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:30', 'end': '09:29', 'period': 'Period 1'},
      {'start': '09:35', 'end': '10:34', 'period': 'Period 2'},
      {'start': '10:40', 'end': '11:39', 'period': 'Period 3'},
      {'start': '11:45', 'end': '12:44', 'period': 'Period 4'},
      {'start': '12:44', 'end': '13:14', 'period': 'Lunch'},
      {'start': '13:20', 'end': '14:19', 'period': 'Period 5'},
      {'start': '14:25', 'end': '15:24', 'period': 'Period 6'},
    ],
    'Tuesday': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:30', 'end': '09:29', 'period': 'Period 1'},
      {'start': '09:35', 'end': '10:34', 'period': 'Period 2'},
      {'start': '10:40', 'end': '11:39', 'period': 'Period 3'},
      {'start': '11:45', 'end': '12:44', 'period': 'Period 4'},
      {'start': '12:44', 'end': '13:14', 'period': 'Lunch'},
      {'start': '13:20', 'end': '14:19', 'period': 'Period 5'},
      {'start': '14:25', 'end': '15:24', 'period': 'Period 6'},
    ],
    'Wednesday': [
      {'start': '08:00', 'end': '09:00', 'period': 'Staff Collaboration'},
      {'start': '09:00', 'end': '10:30', 'period': 'Period 1'},
      {'start': '10:36', 'end': '12:06', 'period': 'Period 3'},
      {'start': '12:06', 'end': '12:36', 'period': 'Lunch'},
      {'start': '12:42', 'end': '13:37', 'period': 'Access'},
      {'start': '13:43', 'end': '15:13', 'period': 'Period 5'},
      {'start': '15:19', 'end': '23:50', 'period': 'Period 7'},
    ],
    'Thursday': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:30', 'end': '10:00', 'period': 'Period 2'},
      {'start': '10:06', 'end': '11:36', 'period': 'Period 4'},
      {'start': '11:36', 'end': '12:06', 'period': 'Lunch'},
      {'start': '12:12', 'end': '12:57', 'period': 'Access'},
      {'start': '13:03', 'end': '14:33', 'period': 'Period 6'},
    ],
    'Friday': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:30', 'end': '09:29', 'period': 'Period 1'},
      {'start': '09:35', 'end': '10:34', 'period': 'Period 2'},
      {'start': '10:40', 'end': '11:39', 'period': 'Period 3'},
      {'start': '11:45', 'end': '12:44', 'period': 'Period 4'},
      {'start': '12:44', 'end': '13:14', 'period': 'Lunch'},
      {'start': '13:20', 'end': '14:19', 'period': 'Period 5'},
      {'start': '14:25', 'end': '15:24', 'period': 'Period 6'},
    ],
    'Minimum Day': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:30', 'end': '09:05', 'period': 'Period 1'},
      {'start': '09:11', 'end': '09:46', 'period': 'Period 2'},
      {'start': '09:52', 'end': '10:27', 'period': 'Period 3'},
      {'start': '10:33', 'end': '11:08', 'period': 'Period 4'},
      {'start': '11:08', 'end': '11:18', 'period': 'Brunch'},
      {'start': '11:24', 'end': '11:59', 'period': 'Period 5'},
      {'start': '12:05', 'end': '12:40', 'period': 'Period 6'},
    ]
  };

  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod);
    super.initState();
    _updateTimeAndClass(); // Initialize time and class
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTimeAndClass());
  }

  void _updateTimeAndClass() {
    DateTime now = DateTime.now();
    //String formattedTime =
    //    '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    
    String formattedTime = DateFormat('hh:mm:ss a').format(now);  // Format time to 12-hour format with AM/PM

    String day = _getDayOfWeek(now);
    List<Map<String, String>> schedule = schedules[day] ?? [];

    String currentClass = 'No Class';
    String timeLeft = '';
    DateTime? notificationTime;

    for (var period in schedule) {
      DateTime start = DateTime(now.year, now.month, now.day,
          int.parse(period['start']!.split(':')[0]),
          int.parse(period['start']!.split(':')[1]));
      DateTime end = DateTime(now.year, now.month, now.day,
          int.parse(period['end']!.split(':')[0]),
          int.parse(period['end']!.split(':')[1]));

      if (now.isAfter(start) && now.isBefore(end)) {
        currentClass = customClassNames[period['period']!] ?? period['period']!;
        timeLeft = _formatDuration(end.difference(now));
        notificationTime = end.subtract(Duration(minutes: 2));
        break;
      }
    }

    String currentSchedule = _getScheduleName(day);

    setState(() {
      _currentTime = formattedTime;
      _currentClass = currentClass;
      _timeLeft = timeLeft;
      _currentSchedule = currentSchedule;
    });

    if (notificationTime != null && now.isAfter(notificationTime) && !notificationSent) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic_channel',
          title: 'EHS Bell Schedule',
          body: '$_currentClass ends in 2 minutes!',
        ),
      );
      notificationSent = true;
    }
  }

  String _getDayOfWeek(DateTime now) {
    switch (now.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  String _getScheduleName(String day) {
    switch (day) {
      case 'Monday':
        return 'Mon/Tue/Fri Schedule';
      case 'Tuesday':
        return 'Mon/Tue/Fri Schedule';
      case 'Friday':
        return 'Mon/Tue/Fri Schedule';
      case 'Minimum Day':
        return "Minimum Day Schedule";
      case 'Wednesday':
        return 'Odd Block Schedule';
      case 'Thursday':
        return 'Even Block Schedule';
      default:
        return 'No schedule';
    }
  }

  void _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(customClassNames: customClassNames),
      ),
    );
    if (result != null) {
      setState(() {
        customClassNames = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EHS Bell Schedule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004d00),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 120),
            if (_currentSchedule != 'No schedule')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _currentSchedule,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            const SizedBox(height: 40),
            const Text(
              'Current Time:',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Text(
              _currentTime,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _currentClass,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            if (_currentClass != 'No Class')
              const Text(
                'Time Left:',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            if (_currentClass != 'No Class')
              Text(
                _timeLeft,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ElevatedButton(
              onPressed: () {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: 1,
                    channelKey: 'basic_channel',
                    title: 'EHS Bell Schedule',
                    body: 'Test notification!',
                  ),
                );
              },
              child: const Text('Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final Map<String, String> customClassNames;

  SettingsPage({required this.customClassNames});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var period in widget.customClassNames.keys)
        period: TextEditingController(text: widget.customClassNames[period]),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF004d00),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Edit your class names:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ..._controllers.keys.map((period) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _controllers[period],
                decoration: InputDecoration(
                  labelText: period,
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color.fromARGB(255, 39, 59, 40).withOpacity(0.3),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Map<String, String> updatedNames = {
            for (var period in _controllers.keys)
              period: _controllers[period]!.text,
          };
          Navigator.pop(context, updatedNames);
        },
        child: const Icon(Icons.save),
        backgroundColor: Color.fromARGB(255, 107, 242, 107),
      ),
    );
  }
}
