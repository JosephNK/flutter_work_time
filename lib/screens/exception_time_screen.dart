import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExceptionTimeScreen extends StatefulWidget {
  @override
  _ExceptionTimeScreenState createState() => _ExceptionTimeScreenState();
}

class _ExceptionTimeScreenState extends State<ExceptionTimeScreen> {
  String _minute = "0";
  String _second = "0";

  @override
  void initState() {
    super.initState();

    this.loadSharedPreferences();
  }

  Future loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int exceptionSecond = (prefs.getInt('ExceptionSecond') ?? 0);
    int minute = exceptionSecond ~/ 60;
    int second = exceptionSecond % 60;
    setState(() {
      _minute = minute.toString();
      _second = second.toString();
    });
  }

  Future setSharedPreferences({int exceptionSec}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('ExceptionSecond', exceptionSec);
  }

  Future onChangePicker(List values) async {
    String minute = values[0].toString();
    String second = values[1].toString();
    setState(() {
      _minute = minute;
      _second = second;
    });
    int sec = int.parse(minute) * 60 + int.parse(second);
    await this.setSharedPreferences(exceptionSec: sec);
  }

  @override
  Widget build(BuildContext context) {
    String minute = _minute.padLeft(2, '0');
    String second = _second.padLeft(2, '0');
    String date = '$minute\분 $second\초';
    List<int> selecteds = [
      int.parse(minute),
      int.parse(second),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('예외시간'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                " $date",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.normal,
                  fontSize: 25.0,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Text('시간 변경'),
                onPressed: () {
                  Picker(
                      adapter: NumberPickerAdapter(data: [
                        NumberPickerColumn(begin: 0, end: 59),
                        NumberPickerColumn(begin: 0, end: 59, jump: 0),
                      ]),
                      delimiter: [
                        PickerDelimiter(
                            child: Container(
                          width: 30.0,
                          alignment: Alignment.center,
                          child: Icon(Icons.more_vert),
                        ))
                      ],
                      hideHeader: true,
                      title: Text("시간설정 (분:초)"),
                      selecteds: selecteds, // [0, 1],
                      selectedTextStyle: TextStyle(color: Colors.blue),
                      onConfirm: (Picker picker, List value) {
                        List values = picker.getSelectedValues();
                        this.onChangePicker(values);
                      }).showDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
