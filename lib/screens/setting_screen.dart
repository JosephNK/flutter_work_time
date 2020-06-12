import 'package:flutter/material.dart';
import 'package:flutter_work_time/common/common.dart';
import 'package:flutter_work_time/screens/exception_time_screen.dart';
import 'package:flutter_work_time/screens/logs_screen.dart';
import 'package:flutter_work_time/screens/notification_time_screen.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(Icons.ac_unit),
              title: Text('예외시간'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Common.push(
                  context,
                  widget: ExceptionTimeScreen(),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.ac_unit),
              title: Text('알림시간'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Common.push(
                  context,
                  widget: NotificationTimeScreen(),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.ac_unit),
              title: Text('기록'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Common.push(
                  context,
                  widget: LogSrcreen(),
                );
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
