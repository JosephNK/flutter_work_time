import 'package:flutter/material.dart';
import 'package:flutter_work_time/common/common.dart';
import 'package:flutter_work_time/database/db.dart';
import 'package:flutter_work_time/models/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogSrcreen extends StatefulWidget {
  @override
  _LogSrcreenState createState() => _LogSrcreenState();
}

class _LogSrcreenState extends State<LogSrcreen> {
  List<DateTimeLog> _items = [];
  int _checkSec = 0;

  @override
  void initState() {
    super.initState();

    this.load();
  }

  Future load() async {
    this._checkSec = await this.loadSharedPreferences();
    List<DateTimeLog> items = await DBHelper().getAllDateTimeLogs();
    setState(() {
      _items = items;
    });
  }

  Future<int> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int exceptionSecond = (prefs.getInt('ExceptionSecond') ?? 0);
    return exceptionSecond;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("기록"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          tooltip: 'Close',
          onPressed: () {
            Common.popRoot(context);
          },
        ),
      ),
      body: Container(
        child: _items.length == 0
            ? Container(
                child: Center(
                  child: Text(
                    "데이타 없음",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return LogItemView(
                    startDateTime: item.startDateTime,
                    endDateTime: item.endDateTime,
                    checkSec: this._checkSec,
                  );
                },
              ),
      ),
    );
  }
}

class LogItemView extends StatelessWidget {
  final String startDateTime;
  final String endDateTime;
  final int checkSec;

  LogItemView({this.startDateTime, this.endDateTime, this.checkSec});

  @override
  Widget build(BuildContext context) {
    final totalSec = DateTime.parse(this.endDateTime).difference(DateTime.parse(this.startDateTime)).inSeconds;
    final isWorkingTime = totalSec > this.checkSec;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 50,
                  child: Text(
                    "시작시간",
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(startDateTime),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 50,
                child: Text(
                  "종료시간",
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(endDateTime),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text(
                      "휴게시간",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      isWorkingTime ? totalSec.toDouble().timeFormatter() : 0.toDouble().timeFormatter(),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 50,
                    child: Text(
                      "예외시간",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      this.checkSec.toDouble().timeFormatter(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Divider(
              color: Colors.grey,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
