import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_work_time/common/common.dart';
import 'package:flutter_work_time/database/db.dart';
import 'package:flutter_work_time/models/log.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final navigatorKey = GlobalKey<NavigatorState>();

  Timer _timer;

  DateTime _startDateTime;

  int _diffSec = 0;
  int _totalSec = 0;
  int _addtionSec = 0;

  int _notificationSec = 0;
  bool _isVibrationing = false;

  get isReady {
    return _diffSec == 0;
  }

  @override
  void initState() {
    super.initState();

    this.load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future load() async {
    print("load");
    _notificationSec = await loadSharedPreferences();
    int totalWorkSec = await DBHelper().getTotalWorkTime();
    setState(() {
      _totalSec = totalWorkSec;
    });
  }

  Future<int> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int notificationSecond = (prefs.getInt('NotificationSecond') ?? 0);
    return notificationSecond;
  }

  Future onStartTimer() async {
    await onStopTimer();

    int seconds = 1;

    setState(() {
      _startDateTime = DateTime.now();
      _diffSec = seconds;
    });

    _timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      int diffSec = DateTime.now().difference(_startDateTime.add(Duration(seconds: -1 + _addtionSec))).inSeconds;
      setState(() {
        _diffSec = diffSec;
      });
      this.doVibration(diffSec: diffSec);
    });
  }

  Future onStopTimer() async {
    int totalWorkSec = await DBHelper().getTotalWorkTime();

    setState(() {
      _totalSec = totalWorkSec;
      _startDateTime = null;
      _diffSec = 0;
      _addtionSec = 0;
    });

    _timer?.cancel();
  }

  Future onPress(bool isReady) async {
    if (isReady) {
      await this.onStartTimer();
      return;
    }

    await DBHelper().insertDateTimeLog(this.createDateTimeLog());
    await this.onStopTimer();
    await this.load();
  }

  Future reset() async {
    await onStopTimer();
    await DBHelper().deleteAllDateTimeLogs();
    await this.load();
  }

  Future doVibration({int diffSec}) async {
    bool isVibration = _notificationSec == 0 ? false : diffSec >= _notificationSec;
    if (_isVibrationing || isVibration == false) {
      return;
    }
    if (await Vibration.hasVibrator()) {
      _isVibrationing = true;
      print("_isVibrationing Start");
      await Vibration.vibrate(duration: 500);
      // await Future.delayed(const Duration(milliseconds: 500), () {});
      _isVibrationing = false;
      print("_isVibrationing End");
    }
  }

  DateTimeLog createDateTimeLog() {
    DateTime startDateTime = _startDateTime; // 시작시간
    final s = DateFormat("yyyy-MM-dd HH:mm:ss").format(startDateTime);
    final e = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final item = DateTimeLog(startDateTime: s, endDateTime: e);
    return item;
  }

  void _showDialog({Function onOK}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reset"),
          content: Text("Do you want to reset?"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                onOK();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNoti = _notificationSec == 0 ? false : _diffSec >= _notificationSec;

    return Scaffold(
      appBar: AppBar(
        title: Text('Break Timer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              this._showDialog(
                onOK: () {
                  this.reset();
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    "Break Time",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _totalSec.toDouble().timeFormatter(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    "Stop Watch",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _diffSec.toDouble().timeFormatter(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                        color: isNoti ? Colors.red : Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  child: Text(
                    isReady ? "시작" : "멈춤",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    this.onPress(isReady);
                  },
                  color: isReady ? Colors.blue : Colors.red,
                ),
              ],
            ),
            // isReady
            //     ? Container()
            //     : Padding(
            //         padding: const EdgeInsets.all(12.0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: <Widget>[
            //             RaisedButton(
            //               child: Text("+10"),
            //               onPressed: () {
            //                 _addtionSec = _addtionSec - 10;
            //                 setState(() {});
            //               },
            //             ),
            //             SizedBox(
            //               width: 10,
            //             ),
            //             RaisedButton(
            //               child: Text("-10"),
            //               onPressed: () {
            //                 _addtionSec = _addtionSec + 10;
            //                 setState(() {});
            //               },
            //             ),
            //           ],
            //         ),
            //       ),
          ],
        ),
      ),
    );
  }
}
