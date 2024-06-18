import 'package:flutter/material.dart';
import 'database_helper.dart';

class ReportScreen extends StatelessWidget {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> _fetchTimeRecords() async {
    return await _databaseHelper.queryAllTimeRecords();
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
        title: Text('Time Records'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTimeRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No time records found'));
          } else {
            final timeRecords = snapshot.data!;
            return ListView.builder(
              itemCount: timeRecords.length,
              itemBuilder: (context, index) {
                final record = timeRecords[index];
                return ListTile(
                  title: Text(record['category']),
                  subtitle: Text(
                      'Time: ${_formatTime(record['elapsed_seconds'])}, Date: ${record['timestamp']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
