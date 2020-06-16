import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_work_time/bloc/timer_bloc.dart';
import 'package:flutter_work_time/common/common.dart';
import 'package:flutter_work_time/database/db.dart';
import 'package:flutter_work_time/models/log.dart';
import 'package:flutter_work_time/widgets/background.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final navigatorKey = GlobalKey<NavigatorState>();

  int _totalSec = 0;
  int _notificationSec = 0;

  @override
  void initState() {
    super.initState();
    this.load();
  }

  @override
  void dispose() {
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

  DateTimeLog createDateTimeLog({@required DateTime startDateTime}) {
    final s = DateFormat("yyyy-MM-dd HH:mm:ss").format(startDateTime);
    final e = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final item = DateTimeLog(startDateTime: s, endDateTime: e);
    return item;
  }

  Future onStartPress(TimerState state) async {
    // int currentSecond = state.second;
    DateTime startDateTime = state.startDateTime;

    if (state is TimerRunning) {
      //DateTime endDateTime = DateTime.now();
      BlocProvider.of<TimerBloc>(context).add(TimerReset(second: 0));

      if (startDateTime != null) {
        await DBHelper().insertDateTimeLog(this.createDateTimeLog(startDateTime: startDateTime));
      }
      await this.load();

      return;
    }

    BlocProvider.of<TimerBloc>(context).add(TimerStarted(second: 0));
  }

  Future onResetPress() async {
    print("onResetPress");
    //DateTime endDateTime = DateTime.now();
    BlocProvider.of<TimerBloc>(context).add(TimerReset(second: 0));

    await this.load();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Break Timer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              this._showDialog(
                onOK: () {
                  this.onResetPress();
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TimerBloc, TimerState>(builder: (context, state) {
        int currentSecond = state.second;
        bool isNoti = _notificationSec == 0 ? false : currentSecond >= _notificationSec;

        return Stack(
          children: <Widget>[
            Background(
              isLoop: true,
            ),
            Container(
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
                            currentSecond.toDouble().timeFormatter(),
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
                          (state is TimerRunning) ? "멈춤" : "시작",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          final TimerState currentState = state;
                          this.onStartPress(currentState);
                        },
                        color: (state is TimerRunning) ? Colors.red : Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
