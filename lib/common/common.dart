import 'package:flutter/material.dart';

class Define {
  static const checkTime = (60 * 6) - 10;
}

class Common {
  static showModal({BuildContext context, GlobalKey<NavigatorState> navigatorKey, Widget widget}) {
    // nested navigation
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return Navigator(
          key: navigatorKey,
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => widget,
          ),
        );
      },
      fullscreenDialog: true,
    ));
  }

  static push(BuildContext context, {Widget widget}) {
    Navigator.push(context, MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return widget;
      },
    ));
  }

  static popRoot(BuildContext context) {
    // //Navigator.of(context).popUntil((route) => route.isFirst),
    // //Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName))
    // //Navigator.of(context).pushNamedAndRemoveUntil(Navigator.defaultRouteName, (Route<dynamic> route) => false),
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
  }
}

extension TimeUtil on double {
  String timeFormatter() {
    Duration duration = Duration(seconds: this.round());
    return [duration.inHours, duration.inMinutes, duration.inSeconds].map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
  }
}
