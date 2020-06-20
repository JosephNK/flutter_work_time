import 'dart:io';

import 'package:flutter_work_time/common/common.dart';
import 'package:flutter_work_time/models/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String tableName = 'DateTimeLog';

class DBHelper {
  DBHelper._();

  static final DBHelper _db = DBHelper._();

  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'DateTimeLog.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      //String query = "CREATE TABLE $tableName(id INTEGER PRIMARY KEY, startDateTime TEXT, endDateTime TEXT)";
      String query =
          "CREATE TABLE $tableName(id TEXT PRIMARY KEY, startDateTime TEXT, endDateTime TEXT)";
      await db.execute(query);
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  // Create
  insertDateTimeLog(DateTimeLog timelog) async {
    final db = await database;
    var res = await db.rawInsert(
        'INSERT INTO $tableName(id, startDateTime, endDateTime) VALUES(?, ?, ?)',
        [timelog.id, timelog.startDateTime, timelog.endDateTime]);
    return res;
  }

  // Read
  getDateTimeLog(String id) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $tableName WHERE id = ?', [id]);
    return res.isNotEmpty
        ? DateTimeLog(
            id: res.first['id'],
            startDateTime: res.first['startDateTime'],
            endDateTime: res.first['endDateTime'])
        : Null;
  }

  // Read All
  Future<List<DateTimeLog>> getAllDateTimeLogs({String date}) async {
    final db = await database;
    String query = 'SELECT * FROM $tableName ORDER BY endDateTime DESC';
    if (date != null) {
      query =
          "SELECT * FROM $tableName WHERE strftime('%Y-%m-%d', startDateTime) = '$date' ORDER BY endDateTime DESC";
    }
    var res = await db.rawQuery(query);
    List<DateTimeLog> list = res.isNotEmpty
        ? res
            .map(
              (c) => DateTimeLog(
                id: c['id'],
                startDateTime: c['startDateTime'],
                endDateTime: c['endDateTime'],
              ),
            )
            .toList()
        : [];

    return list;
  }

  // Delete
  deleteDateTimeLog({String id}) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $tableName WHERE id = ?', [id]);
    return res;
  }

  // Delete All
  deleteAllDateTimeLogs({String date}) async {
    final db = await database;
    String query = 'DELETE FROM $tableName';
    if (date != null) {
      query =
          "DELETE FROM $tableName WHERE strftime('%Y-%m-%d', startDateTime) = '$date'";
    }
    db.rawDelete(query);
  }
}

extension Helper on DBHelper {
  Future<int> getTotalWorkTime({String date}) async {
    final db = await database;
    String query = 'SELECT * FROM $tableName';
    if (date != null) {
      query =
          "SELECT * FROM $tableName WHERE strftime('%Y-%m-%d', startDateTime) = '$date'";
    }
    var res = await db.rawQuery(query);
    List<DateTimeLog> list = res.isNotEmpty
        ? res
            .map(
              (c) => DateTimeLog(
                id: c['id'],
                startDateTime: c['startDateTime'],
                endDateTime: c['endDateTime'],
              ),
            )
            .toList()
        : [];
    final int checkSec = await this.loadSharedPreferences();
    var sum = 0;
    for (var item in list) {
      final totalSec = DateTime.parse(item.endDateTime)
          .difference(DateTime.parse(item.startDateTime))
          .inSeconds;
      final isWorkingTime = totalSec > checkSec;
      if (isWorkingTime) {
        sum = sum + totalSec;
      }
    }
    return sum;
  }

  Future<int> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int exceptionSecond = (prefs.getInt('ExceptionSecond') ?? 0);
    return exceptionSecond;
  }
}
