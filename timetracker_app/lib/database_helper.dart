import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'timetracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE time_records (
        id INTEGER PRIMARY KEY,
        category TEXT,
        elapsed_seconds INTEGER,
        timestamp TEXT
      )
    ''');
  }

  Future<int> insertTimeRecord(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('time_records', row);
  }

  Future<List<Map<String, dynamic>>> queryAllTimeRecords() async {
    Database db = await database;
    return await db.query('time_records');
  }

  Future<void> clearAllTimeRecords() async {
    Database db = await database;
    await db.delete('time_records');
  }
}
