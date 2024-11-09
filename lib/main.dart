import 'package:flutter/material.dart';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(const BellScheduleApp());
}

class BellScheduleApp extends StatelessWidget {
  const BellScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EHS Bell Schedule',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.transparent,
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
  String _periodDuration = '';
  bool notificationSent = false;
  int notificationTimeBeforeEnd = 2; // Default to 2 minutes before class ends
  bool passPeriodNotificationsEnabled = false; // Default to no notifications for passing periods
  bool is24HourFormat = false; // Default to 12-hour format
  bool hasZeroPeriod = true; // Default to having zero period
  Map<String, String> customClassNames = {
    'Period 0': 'Period 0',
    'Period 1': 'Period 1',
    'Period 2': 'Period 2',
    'Period 3': 'Period 3',
    'Period 4': 'Period 4',
    'Period 5': 'Period 5',
    'Period 6': 'Period 6',
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
      {'start': '11:08', 'end': '11:14', 'period': 'Passing Period'},
      {'start': '11:14', 'end': '11:49', 'period': 'Period 5'},
      {'start': '11:49', 'end': '11:55', 'period': 'Passing Period'},
      {'start': '11:55', 'end': '12:30', 'period': 'Period 6'},
    ],
  };

  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );
    super.initState();
    _loadSettings(); // Load settings when the app starts
    _scheduleAccessNotification(); 
    _updateTimeAndClass(); // Initialize time and class
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTimeAndClass());
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationTimeBeforeEnd = prefs.getInt('notificationTimeBeforeEnd') ?? 2;
      passPeriodNotificationsEnabled = prefs.getBool('passPeriodNotificationsEnabled') ?? false;
      is24HourFormat = prefs.getBool('is24HourFormat') ?? false;
      hasZeroPeriod = prefs.getBool('hasZeroPeriod') ?? true;
      List<String>? savedCustomClassNames = prefs.getStringList('customClassNames');
      if (savedCustomClassNames != null) {
        customClassNames = {
          for (String entry in savedCustomClassNames)
            entry.split(':')[0]: entry.split(':')[1],
        };
      }
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationTimeBeforeEnd', notificationTimeBeforeEnd);
    await prefs.setBool('passPeriodNotificationsEnabled', passPeriodNotificationsEnabled);
    await prefs.setBool('is24HourFormat', is24HourFormat);
    await prefs.setBool('hasZeroPeriod', hasZeroPeriod);
    await prefs.setStringList(
      'customClassNames',
      customClassNames.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
  }

  void _updateTimeAndClass() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat(is24HourFormat ? 'HH:mm:ss' : 'hh:mm:ss a').format(now); // Format time to 12-hour or 24-hour format

    String day = _getDayOfWeek(now);
    List<Map<String, String>> schedule = schedules[day] ?? [];

    String currentClass = 'No Class';
    String timeLeft = '';
    String periodDuration = '';
    DateTime? notificationTime;

    for (var period in schedule) {
      if (!hasZeroPeriod && period['period'] == 'Period 0') continue;

      DateTime start = DateTime(now.year, now.month, now.day,
          int.parse(period['start']!.split(':')[0]),
          int.parse(period['start']!.split(':')[1]));
      DateTime end = DateTime(now.year, now.month, now.day,
          int.parse(period['end']!.split(':')[0]),
          int.parse(period['end']!.split(':')[1]));

      if (now.isAfter(start) && now.isBefore(end)) {
        currentClass = customClassNames[period['period']] ?? period['period']!;
        timeLeft = _formatDuration(end.difference(now));
        periodDuration = '${DateFormat(is24HourFormat ? 'HH:mm' : 'hh:mm a').format(start)} - ${DateFormat(is24HourFormat ? 'HH:mm' : 'hh:mm a').format(end)}';

        if (currentClass == 'Passing Period') {
          if (passPeriodNotificationsEnabled) {
            notificationTime = end.subtract(Duration(minutes: 1));
          }
        } else {
          notificationTime = end.subtract(Duration(minutes: notificationTimeBeforeEnd));
        }
        break;
      }
    }

    String currentSchedule = _getScheduleName(day);

    setState(() {
      _currentTime = formattedTime;
      _currentClass = currentClass;
      _timeLeft = timeLeft;
      _currentSchedule = currentSchedule;
      _periodDuration = periodDuration;
    });

    if (notificationTime != null && !notificationSent) {
      _scheduleNotification(notificationTime, _currentClass);
      notificationSent = true;
    }
  }

  void _scheduleNotification(DateTime scheduledTime, String periodName) {
    int notificationId = scheduledTime.hashCode % 1000000; // Unique ID for each notification

    String notificationMessage = periodName == 'Passing Period'
        ? 'Passing Period ends in 1 minute!'
        : '$periodName ends in $notificationTimeBeforeEnd minutes!';

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'basic_channel',
        title: 'EHS Bell Schedule',
        body: notificationMessage,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
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
      case 'Tuesday':
      case 'Friday':
        return 'Mon/Tue/Fri Schedule';
      case 'Wednesday':
        return 'Wednesday Schedule';
      case 'Thursday':
        return 'Thursday Schedule';
      case 'Minimum Day':
        return 'Minimum Day Schedule';
      default:
        return 'No schedule'; // Default = "No schedule"
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          customClassNames: customClassNames,
          testNotificationCallback: _testNotification,
          notificationTimeBeforeEnd: notificationTimeBeforeEnd,
          passPeriodNotificationsEnabled: passPeriodNotificationsEnabled,
          onNotificationTimeChanged: (int value) {
            setState(() {
              notificationTimeBeforeEnd = value;
              notificationSent = false;
              _saveSettings();  // Save settings when changed
            });
          },
          onPassPeriodNotificationsChanged: (bool value) {
            setState(() {
              passPeriodNotificationsEnabled = value;
              notificationSent = false;
              _saveSettings();  // Save settings when changed
            });
          },
          is24HourFormat: is24HourFormat,
          hasZeroPeriod: hasZeroPeriod,
          on24HourFormatChanged: (bool value) {
            setState(() {
              is24HourFormat = value;
              _saveSettings();  // Save settings when changed
            });
          },
          onZeroPeriodChanged: (bool value) {
            setState(() {
              hasZeroPeriod = value;
              _saveSettings();  // Save settings when changed
            });
          },
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          customClassNames = result;
          _saveSettings();  // Save settings when changed
        });
      }
    });
  }

  void _openInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InformationPage(
          schedules: schedules,
          customClassNames: customClassNames,
          is24HourFormat: is24HourFormat,
          hasZeroPeriod: hasZeroPeriod,
        ),
      ),
    );
  }

  void _testNotification() {
    _scheduleTestNotification(DateTime.now().add(Duration(seconds: 1)));
  }

  void _scheduleTestNotification(DateTime scheduledTime) {
    int notificationId = scheduledTime.hashCode % 1000000; // Unique ID for each notification

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'basic_channel',
        title: 'EHS Bell Schedule',
        body: 'Test Notification!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
  }
  void _scheduleAccessNotification() {
  // Schedule notification for Sunday at 8 PM
  DateTime now = DateTime.now();
  DateTime nextSunday = now.add(Duration(days: (7 - now.weekday) % 7));
  DateTime scheduledTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 20, 0);

  int notificationId = scheduledTime.hashCode % 1000000; // Unique ID for the notification

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: notificationId,
      channelKey: 'basic_channel',
      title: 'Sign Up for Access!',
      body: 'This is your reminder to sign up for access.',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar.fromDate(date: scheduledTime, repeats: true),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.info, color: Colors.white),
          onPressed: _openInformation,
        ),
        title: Center(
          child: Column(
            children: [
              Text(
                DateFormat('E, MMM d').format(DateTime.now()),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                _currentSchedule,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _currentClass == 'No Class'
              ? Center(
                  child: Text(
                    _currentClass,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 120.0), // Adjust padding here
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (_currentClass != 'No Class')
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: 1 - _calculateProgress(), // Countdown counterclockwise
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _timeLeft,
                                        style: const TextStyle(fontSize: 30, color: Colors.white),
                                      ),
                                      Text(
                                        'left',
                                        style: const TextStyle(fontSize: 20, color: Colors.white), // Increased font size
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          _currentClass,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        if (_currentClass != 'No Class')
                          Text(
                            _periodDuration,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  double _calculateProgress() {
    DateTime now = DateTime.now();
    String day = _getDayOfWeek(now);
    List<Map<String, String>> schedule = schedules[day] ?? [];

    for (var period in schedule) {
      if (!hasZeroPeriod && period['period'] == 'Period 0') continue;

      DateTime start = DateTime(now.year, now.month, now.day,
          int.parse(period['start']!.split(':')[0]),
          int.parse(period['start']!.split(':')[1]));
      DateTime end = DateTime(now.year, now.month, now.day,
          int.parse(period['end']!.split(':')[0]),
          int.parse(period['end']!.split(':')[1]));

      if (now.isAfter(start) && now.isBefore(end)) {
        double totalDuration = end.difference(start).inSeconds.toDouble();
        double elapsedDuration = now.difference(start).inSeconds.toDouble();
        return elapsedDuration / totalDuration;
      }
    }
    return 0.0;
  }
}

class SettingsPage extends StatelessWidget {
  final Map<String, String> customClassNames;
  final VoidCallback testNotificationCallback;
  final int notificationTimeBeforeEnd;
  final bool passPeriodNotificationsEnabled;
  final ValueChanged<int> onNotificationTimeChanged;
  final ValueChanged<bool> onPassPeriodNotificationsChanged;
  final bool is24HourFormat;
  final bool hasZeroPeriod;
  final ValueChanged<bool> on24HourFormatChanged;
  final ValueChanged<bool> onZeroPeriodChanged;

  SettingsPage({
    required this.customClassNames,
    required this.testNotificationCallback,
    required this.notificationTimeBeforeEnd,
    required this.passPeriodNotificationsEnabled,
    required this.onNotificationTimeChanged,
    required this.onPassPeriodNotificationsChanged,
    required this.is24HourFormat,
    required this.hasZeroPeriod,
    required this.on24HourFormatChanged,
    required this.onZeroPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: const Text('Edit Class Names', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditClassNamesPage(customClassNames: customClassNames, hasZeroPeriod: hasZeroPeriod),
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
                        notificationTimeBeforeEnd: notificationTimeBeforeEnd,
                        passPeriodNotificationsEnabled: passPeriodNotificationsEnabled,
                        onNotificationTimeChanged: onNotificationTimeChanged,
                        onPassPeriodNotificationsChanged: onPassPeriodNotificationsChanged,
                      ),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white, height: 2),
              ListTile(
                title: const Text('Other Settings', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherSettingsPage(
                        is24HourFormat: is24HourFormat,
                        hasZeroPeriod: hasZeroPeriod,
                        on24HourFormatChanged: on24HourFormatChanged,
                        onZeroPeriodChanged: onZeroPeriodChanged,
                      ),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white, height: 2),
              // New ListTile for Feedback Form at the end
              ListTile(
                title: const Text('Share Feedback', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () async {
                  const url = 'https://docs.google.com/forms/d/e/1FAIpQLScSu5zGeHd76Uukl2vmE4dMgj-q0bMv5wUooP5O3Nsu_S4A7g/viewform'; // Replace with your actual URL
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
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
        ),
      ),
    );
  }
}

class EditClassNamesPage extends StatefulWidget {
  final Map<String, String> customClassNames;
  final bool hasZeroPeriod;

  EditClassNamesPage({required this.customClassNames, required this.hasZeroPeriod});

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

  void _saveClassNames() async {
    Map<String, String> updatedNames = {
      for (var period in _controllers.keys)
        period: _controllers[period]!.text,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'customClassNames',
      updatedNames.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
    Navigator.pop(context, updatedNames);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Class Names', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              ..._controllers.keys.where((period) => widget.hasZeroPeriod || period != 'Period 0').map((period) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                onPressed: _saveClassNames,
                child: const Text('Save Class Names'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  final VoidCallback testNotificationCallback;
  final int notificationTimeBeforeEnd;
  final bool passPeriodNotificationsEnabled;
  final ValueChanged<int> onNotificationTimeChanged;
  final ValueChanged<bool> onPassPeriodNotificationsChanged;

  NotificationsPage({
    required this.testNotificationCallback,
    required this.notificationTimeBeforeEnd,
    required this.passPeriodNotificationsEnabled,
    required this.onNotificationTimeChanged,
    required this.onPassPeriodNotificationsChanged,
  });

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _notificationTimeBeforeEnd = 2; // Default to 2 minutes
  bool _passPeriodNotificationsEnabled = false; // Default to no notifications for passing periods

  @override
  void initState() {
    super.initState();
    _notificationTimeBeforeEnd = widget.notificationTimeBeforeEnd;
    _passPeriodNotificationsEnabled = widget.passPeriodNotificationsEnabled;
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationTimeBeforeEnd', _notificationTimeBeforeEnd);
    await prefs.setBool('passPeriodNotificationsEnabled', _passPeriodNotificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
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
                    _saveSettings();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 33, 59, 34).withOpacity(0.3),
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
        ),
      ),
    );
  }
}

class OtherSettingsPage extends StatefulWidget {
  final bool is24HourFormat;
  final bool hasZeroPeriod;
  final ValueChanged<bool> on24HourFormatChanged;
  final ValueChanged<bool> onZeroPeriodChanged;

  OtherSettingsPage({
    required this.is24HourFormat,
    required this.hasZeroPeriod,
    required this.on24HourFormatChanged,
    required this.onZeroPeriodChanged,
  });

  @override
  _OtherSettingsPageState createState() => _OtherSettingsPageState();
}

class _OtherSettingsPageState extends State<OtherSettingsPage> {
  late bool _is24HourFormat;
  late bool _hasZeroPeriod;

  @override
  void initState() {
    super.initState();
    _is24HourFormat = widget.is24HourFormat;
    _hasZeroPeriod = widget.hasZeroPeriod;
  }

  void _saveSettings() async {
    widget.on24HourFormatChanged(_is24HourFormat);
    widget.onZeroPeriodChanged(_hasZeroPeriod);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is24HourFormat', _is24HourFormat);
    await prefs.setBool('hasZeroPeriod', _hasZeroPeriod);
    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Other Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SwitchListTile(
                title: const Text('24-Hour Time Format', style: TextStyle(color: Colors.white)),
                value: _is24HourFormat,
                onChanged: (bool value) {
                  setState(() {
                    _is24HourFormat = value;
                  });
                },
              ),
              const Divider(color: Colors.white, height: 2),
              SwitchListTile(
                title: const Text('Show Zero Period', style: TextStyle(color: Colors.white)),
                value: _hasZeroPeriod,
                onChanged: (bool value) {
                  setState(() {
                    _hasZeroPeriod = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('About', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const Text(
                    'Contributors',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,  // Increased font size
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Alex Liao - Developer\n'
                    'Justin Fu - Developer\n'
                    'Sanjana Gowda - Developer\n'
                    'Jack Wu - Designer\n'
                    'Shely Jain - Idea',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'From the first graduating class of Emerald High, Class of 2027.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'This project is open source. View the code on ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                        TextSpan(
                          text: 'GitHub',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18.0,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url = 'https://github.com/alexliao95311/ehs-bell-schedule';
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                        ),
                        const TextSpan(
                          text: '.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class InformationPage extends StatelessWidget {
  final Map<String, List<Map<String, String>>> schedules;
  final Map<String, String> customClassNames;
  final bool is24HourFormat;
  final bool hasZeroPeriod;

  InformationPage({required this.schedules, required this.customClassNames, required this.is24HourFormat, required this.hasZeroPeriod});

  List<Map<String, String>> _filterSchedule(List<Map<String, String>> schedule) {
    return schedule
        .where((period) => period['period'] != 'Passing Period' && (hasZeroPeriod || period['period'] != 'Period 0'))
        .toList();
  }

  String _formatTime(String time) {
    DateTime dateTime = DateFormat('HH:mm').parse(time);
    return DateFormat(is24HourFormat ? 'HH:mm' : 'hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String day = DateFormat('EEEE').format(now);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('All Schedules', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back arrow white
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildScheduleSection('Today\'s Schedule (${day})', schedules[day] ?? []),
              _buildScheduleSection('Mon/Tue/Fri Schedule', schedules['Monday'] ?? []),
              _buildScheduleSection('Wednesday Schedule', schedules['Wednesday'] ?? []),
              _buildScheduleSection('Thursday Schedule', schedules['Thursday'] ?? []),
              _buildScheduleSection('Minimum Day Schedule', schedules['Minimum Day'] ?? []),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(String title, List<Map<String, String>> schedule) {
    List<Map<String, String>> filteredSchedule = _filterSchedule(schedule);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        if (filteredSchedule.isEmpty)
          const Text('No schedule today', style: TextStyle(fontSize: 16, color: Colors.white)),
        ...filteredSchedule.asMap().entries.expand((entry) {
          int index = entry.key;
          Map<String, String> period = entry.value;
          String periodName = customClassNames[period['period']] ?? period['period']!;
          return [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  periodName,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  '${_formatTime(period['start']!)} - ${_formatTime(period['end']!)}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            if (index < filteredSchedule.length - 1) Divider(color: Colors.grey[400]),
          ];
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}