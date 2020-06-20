import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_work_time/common/common.dart';
import 'package:flutter_work_time/database/db.dart';
import 'package:flutter_work_time/models/log.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());

    this._checkSec = await this.loadSharedPreferences();

    await loadDB(date: date);
  }

  Future loadDB({String date}) async {
    List<DateTimeLog> items = await DBHelper().getAllDateTimeLogs(date: date);
    setState(() {
      _items = items;
    });
  }

  Future<int> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int exceptionSecond = (prefs.getInt('ExceptionSecond') ?? 0);
    return exceptionSecond;
  }

  Future onResetPress() async {
    await DBHelper().deleteAllDateTimeLogs();
    await this.load();
  }

  Future onDeleteRow(BuildContext context, DateTimeLog item) async {
    final id = item.id;
    await DBHelper().deleteDateTimeLog(id: id);
    await this.load();
    _showSnackBar(context, "삭제되었습니다.");
  }

  Future onDatePickerConfirm(DateTime dateTime) async {
    String date = DateFormat("yyyy-MM-dd").format(dateTime);
    await loadDB(date: date);
  }

  Widget getSlidableWithItem(BuildContext context, DateTimeLog item) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: LogItemView(
          startDateTime: item.startDateTime,
          endDateTime: item.endDateTime,
          checkSec: this._checkSec,
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '삭제',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            onDeleteRow(context, item);
          },
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Common.showAlert(
                context: context,
                title: "기록 초기화",
                content: "기록을 전체 초기화 하시겠습니까?",
                onOK: () {
                  this.onResetPress();
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                onConfirm: (date) {
                  onDatePickerConfirm(date);
                },
                currentTime: DateTime.now(),
                locale: LocaleType.ko,
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
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
                itemCount: _items.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    String checkSec = this._checkSec.toDouble().timeFormatter();
                    return Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 18, 0),
                            child: Text("예외시간 $checkSec"),
                          ),
                        ],
                      ),
                    );
                  }
                  final item = _items[index - 1];
                  return this.getSlidableWithItem(context, item);
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
    DateTime startDateTime = DateTime.parse(this.startDateTime);
    DateTime endDateTime = DateTime.parse(this.endDateTime);

    final totalSec = endDateTime.difference(startDateTime).inSeconds;
    final isWorkingTime = totalSec > this.checkSec;

    String startDate = DateFormat("yyyy.MM.dd").format(startDateTime);
    String startTime = DateFormat("HH:mm:ss").format(startDateTime);
    String endTime = DateFormat("HH:mm:ss").format(endDateTime);

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
                    "일      자",
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(startDate),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 50,
                  child: Text(
                    "시      간",
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "$startTime ~ $endTime",
                  ),
                ),
              ],
            ),
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
                      isWorkingTime
                          ? totalSec.toDouble().timeFormatter()
                          : 0.toDouble().timeFormatter(),
                    ),
                  ),
                ],
              ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: <Widget>[
              //     Container(
              //       width: 50,
              //       child: Text(
              //         "예외시간",
              //         textAlign: TextAlign.right,
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 10),
              //       child: Text(
              //         this.checkSec.toDouble().timeFormatter(),
              //       ),
              //     ),
              //   ],
              // ),
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
