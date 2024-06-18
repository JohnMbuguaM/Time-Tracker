import 'package:flutter/material.dart';
import 'dart:async';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    'Coding',
    'Medali',
    'SJob',
    'Family',
    'Time Out Breaks',
    'Relaxing',
    'Sleeping',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Know How you use your 24Hrs'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TimerScreen(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final String category;

  TimerScreen({required this.category});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
      if (_elapsedSeconds % 300 == 0) {
        // Every 5 minutes
        // Play a beep sound (add your sound playing logic here)
      }
      if (_elapsedSeconds >= 900) {
        // After 15 minutes
        _timer?.cancel();
        _showContinueDialog();
      }
    });
  }

  void _showContinueDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Continue?'),
          content: Text('15 minutes have passed. Do you want to continue?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startTimer();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveTimeRecord();
                setState(() {
                  _isRunning = false;
                });
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _saveTimeRecord() async {
    DateTime now = DateTime.now();
    Map<String, dynamic> row = {
      'category': widget.category,
      'elapsed_seconds': _elapsedSeconds,
      'timestamp': now.toIso8601String(),
    };
    await _databaseHelper.insertTimeRecord(row);
    // Print for debugging
    print(
        'Time recorded: ${_elapsedSeconds} seconds for ${widget.category} on $now');
  }

  void _stopTimer() {
    _timer?.cancel();
    _saveTimeRecord();
    setState(() {
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer for ${widget.category}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Time elapsed: ${_formatTime(_elapsedSeconds)}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            _isRunning
                ? ElevatedButton(
                    onPressed: _stopTimer,
                    child: Text('End Timer'),
                  )
                : ElevatedButton(
                    onPressed: _startTimer,
                    child: Text('Start Timer'),
                  ),
          ],
        ),
      ),
    );
  }
}
