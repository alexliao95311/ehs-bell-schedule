import 'package:flutter/material.dart';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'notification_controller.dart';

void main() async {
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Basic notifications channel',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        channelGroupKey: "basic_channel_group",
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic Group',
      )
    ],
  );

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
        scaffoldBackgroundColor: Color.fromARGB(255, 2, 51, 2),
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
  bool notificationsEnabled = true;
  int notificationTimeBeforeEnd = 2; // Default to 2 minutes before class ends
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
      {'start': '08:20', 'end': '08:30', 'period': 'Passing Period'},
      {'start': '08:30', 'end': '09:29', 'period': 'Period 1'},
      {'start': '09:29', 'end': '09:35', 'period': 'Passing Period'},
      {'start': '09:35', 'end': '10:34', 'period': 'Period 2'},
      {'start': '10:34', 'end': '10:40', 'period': 'Passing Period'},
      {'start': '10:40', 'end': '11:39', 'period': 'Period 3'},
      {'start': '11:39', 'end': '11:45', 'period': 'Passing Period'},
      {'start': '11:45', 'end': '12:44', 'period': 'Period 4'},
      {'start': '12:44', 'end': '13:14', 'period': 'Lunch'},
      {'start': '13:14', 'end': '13:20', 'period': 'Passing Period'},
      {'start': '13:20', 'end': '14:19', 'period': 'Period 5'},
      {'start': '14:19', 'end': '14:25', 'period': 'Passing Period'},
      {'start': '14:25', 'end': '15:24', 'period': 'Period 6'},
    ],
    'Tuesday': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:20', 'end': '08:30', 'period': 'Passing Period'},
      {'start': '08:30', 'end': '09:29', 'period': 'Period 1'},
      {'start': '09:29', 'end': '09:35', 'period': 'Passing Period'},
      {'start': '09:35', 'end': '10:34', 'period': 'Period 2'},
      {'start': '10:34', 'end': '10:40', 'period': 'Passing Period'},
      {'start': '10:40', 'end': '11:39', 'period': 'Period 3'},
      {'start': '11:39', 'end': '11:45', 'period': 'Passing Period'},
      {'start': '11:45', 'end': '12:44', 'period': 'Period 4'},
      {'start': '12:44', 'end': '13:14', 'period': 'Lunch'},
      {'start': '13:14', 'end': '13:20', 'period': 'Passing Period'},
      {'start': '13:20', 'end': '14:19', 'period': 'Period 5'},
      {'start': '14:19', 'end': '14:25', 'period': 'Passing Period'},
      {'start': '14:25', 'end': '15:24', 'period': 'Period 6'},
    ],
    'Wednesday': [
      {'start': '08:00', 'end': '09:00', 'period': 'Staff Collaboration'},
      {'start': '09:00', 'end': '10:30', 'period': 'Period 1'},
      {'start': '10:30', 'end': '10:36', 'period': 'Passing Period'},
      {'start': '10:36', 'end': '12:06', 'period': 'Period 3'},
      {'start': '12:06', 'end': '12:36', 'period': 'Lunch'},
      {'start': '12:36', 'end': '12:42', 'period': 'Passing Period'},
      {'start': '12:42', 'end': '13:37', 'period': 'Access'},
      {'start': '13:37', 'end': '13:43', 'period': 'Passing Period'},
      {'start': '13:43', 'end': '15:13', 'period': 'Period 5'},
    ],
    'Thursday': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:20', 'end': '08:30', 'period': 'Passing Period'},
      {'start': '08:30', 'end': '10:00', 'period': 'Period 2'},
      {'start': '10:00', 'end': '10:06', 'period': 'Passing Period'},
      {'start': '10:06', 'end': '11:36', 'period': 'Period 4'},
      {'start': '11:36', 'end': '12:06', 'period': 'Lunch'},
      {'start': '12:06', 'end': '12:12', 'period': 'Passing Period'},
      {'start': '12:12', 'end': '12:57', 'period': 'Access'},
      {'start': '12:57', 'end': '13:03', 'period': 'Passing Period'},
      {'start': '13:03', 'end': '14:33', 'period': 'Period 6'},
    ],
    'Friday': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:20', 'end': '08:30', 'period': 'Passing Period'},
      {'start': '08:30', 'end': '09:29', 'period': 'Period 1'},
      {'start': '09:29', 'end': '09:35', 'period': 'Passing Period'},
      {'start': '09:35', 'end': '10:34', 'period': 'Period 2'},
      {'start': '10:34', 'end': '10:40', 'period': 'Passing Period'},
      {'start': '10:40', 'end': '11:39', 'period': 'Period 3'},
      {'start': '11:39', 'end': '11:45', 'period': 'Passing Period'},
      {'start': '11:45', 'end': '12:44', 'period': 'Period 4'},
      {'start': '12:44', 'end': '13:14', 'period': 'Lunch'},
      {'start': '13:14', 'end': '13:20', 'period': 'Passing Period'},
      {'start': '13:20', 'end': '14:19', 'period': 'Period 5'},
      {'start': '14:19', 'end': '14:25', 'period': 'Passing Period'},
      {'start': '14:25', 'end': '15:24', 'period': 'Period 6'},
    ],
    'Minimum Day': [
      {'start': '07:15', 'end': '08:20', 'period': 'Period 0'},
      {'start': '08:20', 'end': '08:30', 'period': 'Passing Period'},
      {'start': '08:30', 'end': '09:05', 'period': 'Period 1'},
      {'start': '09:05', 'end': '09:11', 'period': 'Passing Period'},
      {'start': '09:11', 'end': '09:46', 'period': 'Period 2'},
      {'start': '09:46', 'end': '09:52', 'period': 'Passing Period'},
      {'start': '09:52', 'end': '10:27', 'period': 'Period 3'},
      {'start': '10:27', 'end': '10:33', 'period': 'Passing Period'},
      {'start': '10:33', 'end': '11:08', 'period': 'Period 4'},
      {'start': '11:08', 'end': '11:18', 'period': 'Brunch'},
      {'start': '11:18', 'end': '11:24', 'period': 'Passing Period'},
      {'start': '11:24', 'end': '11:59', 'period': 'Period 5'},
      {'start': '11:59', 'end': '12:05', 'period': 'Passing Period'},
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
        currentClass = customClassNames[period['period']] ?? period['period']!;
        timeLeft = _formatDuration(end.difference(now));
        notificationTime = end.subtract(Duration(minutes: notificationTimeBeforeEnd));
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

    if (notificationsEnabled && notificationTime != null && now.isAfter(notificationTime) && !notificationSent) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic_channel',
          title: 'EHS Bell Schedule',
          body: '$_currentClass ends in $notificationTimeBeforeEnd minutes!',
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          customClassNames: customClassNames,
          testNotificationCallback: _testNotification,
          notificationsEnabled: notificationsEnabled,
          notificationTimeBeforeEnd: notificationTimeBeforeEnd,
          onNotificationsChanged: (bool value) {
            setState(() {
              notificationsEnabled = value;
            });
          },
          onNotificationTimeChanged: (int value) {
            setState(() {
              notificationTimeBeforeEnd = value;
            });
          },
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          customClassNames = result;
        });
      }
    });
  }

  void _testNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'EHS Bell Schedule',
        body: 'Test notification!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EHS Bell Schedule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 2, 51, 2),
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
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Map<String, String> customClassNames;
  final VoidCallback testNotificationCallback;
  final bool notificationsEnabled;
  final int notificationTimeBeforeEnd;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<int> onNotificationTimeChanged;

  SettingsPage({
    required this.customClassNames,
    required this.testNotificationCallback,
    required this.notificationsEnabled,
    required this.notificationTimeBeforeEnd,
    required this.onNotificationsChanged,
    required this.onNotificationTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 2, 51, 2),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Edit Class Names', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditClassNamesPage(customClassNames: customClassNames),
                ),
              ).then((result) {
                if (result != null) {
                  Navigator.pop(context, result);
                }
              });
            },
          ),
          const Divider(color: Colors.white, height: 2),
          ListTile(
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(
                    testNotificationCallback: testNotificationCallback,
                    notificationsEnabled: notificationsEnabled,
                    notificationTimeBeforeEnd: notificationTimeBeforeEnd,
                    onNotificationsChanged: onNotificationsChanged,
                    onNotificationTimeChanged: onNotificationTimeChanged,
                  ),
                ),
              );
            },
          ),
          const Divider(color: Colors.white, height: 2),
          ListTile(
            title: const Text('About', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EditClassNamesPage extends StatefulWidget {
  final Map<String, String> customClassNames;

  EditClassNamesPage({required this.customClassNames});

  @override
  _EditClassNamesPageState createState() => _EditClassNamesPageState();
}

class _EditClassNamesPageState extends State<EditClassNamesPage> {
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
        title: const Text('Edit Class Names', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 2, 51, 2),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
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
                  suffixIcon: _controllers[period]!.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _controllers[period]!.clear();
                            });
                          },
                        )
                      : null,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (text) {
                  setState(() {});
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Map<String, String> updatedNames = {
                for (var period in _controllers.keys)
                  period: _controllers[period]!.text,
              };
              Navigator.pop(context, updatedNames);
            },
            child: const Text('Save Class Names'),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  final VoidCallback testNotificationCallback;
  final bool notificationsEnabled;
  final int notificationTimeBeforeEnd;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<int> onNotificationTimeChanged;

  NotificationsPage({
    required this.testNotificationCallback,
    required this.notificationsEnabled,
    required this.notificationTimeBeforeEnd,
    required this.onNotificationsChanged,
    required this.onNotificationTimeChanged,
  });

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notificationsEnabled = false;
  int _notificationTimeBeforeEnd = 2; // Default to 2 minutes

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.notificationsEnabled;
    _notificationTimeBeforeEnd = widget.notificationTimeBeforeEnd;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 2, 51, 2),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notify me before class ends:', style: TextStyle(color: Colors.white)),
            DropdownButtonFormField<int>(
              value: _notificationTimeBeforeEnd,
              items: const [
                DropdownMenuItem(
                  child: Text('No Notification'),
                  value: -1,
                ),
                DropdownMenuItem(
                  child: Text('30 seconds'),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text('1 minute'),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text('2 minutes'),
                  value: 2,
                ),
                DropdownMenuItem(
                  child: Text('3 minutes'),
                  value: 3,
                ),
                DropdownMenuItem(
                  child: Text('5 minutes'),
                  value: 5,
                ),
              ],
              onChanged: (int? value) {
                setState(() {
                  _notificationTimeBeforeEnd = value!;
                });
                widget.onNotificationTimeChanged(value!);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 33, 59, 34),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: Colors.white),
              dropdownColor: Color.fromARGB(255, 33, 59, 34),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: widget.testNotificationCallback,
                child: const Text('Test Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 2, 51, 2),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: const Text(
            'Developed by Alex Liao\n'
            'Designed by Sanjana Gowda, Shely Jain, Jan Palma, Jack Wu\n\n'
            'From the first graduating class of Emerald High, Class of 2027.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

