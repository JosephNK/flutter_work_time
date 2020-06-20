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
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    int totalWorkSec = await DBHelper().getTotalWorkTime(date: date);
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
    String hashCode = UniqueKey().hashCode.toString();
    final id = "$s$e$hashCode"
        .replaceAll(":", "")
        .replaceAll("-", "")
        .replaceAll(" ", "");
    final item = DateTimeLog(id: id, startDateTime: s, endDateTime: e);
    return item;
  }

  Future onStartPress(TimerState state) async {
    // int currentSecond = state.second;
    DateTime startDateTime = state.startDateTime;

    if (state is TimerRunning) {
      //DateTime endDateTime = DateTime.now();
      BlocProvider.of<TimerBloc>(context).add(TimerReset(second: 0));

      if (startDateTime != null) {
        await DBHelper().insertDateTimeLog(
            this.createDateTimeLog(startDateTime: startDateTime));
      }
      await this.load();

      return;
    }

    BlocProvider.of<TimerBloc>(context).add(TimerStarted(second: 0));
  }

  Future onResetPress() async {
    //DateTime endDateTime = DateTime.now();
    BlocProvider.of<TimerBloc>(context).add(TimerReset(second: 0));

    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    await DBHelper().deleteAllDateTimeLogs(date: date);
    await this.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('휴계 시간'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Common.showAlert(
                context: context,
                title: "타이머 초기화",
                content: "타이머 초기화 하시겠습니까?\n(금일 기록도 삭제 됩니다.)",
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
        int notiSecond = state.notiSecond;

        bool isNoti = notiSecond == 0 ? false : currentSecond >= notiSecond;

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
                        color:
                            (state is TimerRunning) ? Colors.red : Colors.blue,
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
