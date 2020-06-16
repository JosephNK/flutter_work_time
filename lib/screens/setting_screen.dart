import 'package:flutter/material.dart';
import 'package:flutter_work_time/common/common.dart';
import 'package:flutter_work_time/screens/exception_time_screen.dart';
import 'package:flutter_work_time/screens/logs_screen.dart';
import 'package:flutter_work_time/screens/notification_time_screen.dart';
import 'package:wakelock/wakelock.dart';

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
            WakeListTile(),
          ],
        ).toList(),
      ),
    );
  }
}

class WakeListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Wakelock.isEnabled,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Text('wakelock is currently ${snapshot.data ? 'enabled' : 'disabled'}'),
          ),
        );
      },
    );
  }
}
