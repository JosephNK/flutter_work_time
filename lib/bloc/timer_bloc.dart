import 'dart:async';

import 'package:flutter_work_time/common/manager.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_work_time/ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  int _notificationSec = 0;
  int _vibrationSec = 0;
  int _currentDelayVibrationCount = 0;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => TimerReady(0);

  @override
  void onTransition(Transition<TimerEvent, TimerState> transition) {
    super.onTransition(transition);
  }

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is TimerStarted) {
      yield* _mapTimerStartedToState(event);
    } else if (event is TimerTicked) {
      yield* _mapTimerTickedToState(event);
    } else if (event is TimerReset) {
      yield* _mapTimerResetToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapTimerStartedToState(TimerStarted start) async* {
    int second = start.second + 1;
    DateTime startDateTime = DateTime.now();
    second = DateTime.now().difference(startDateTime.add(Duration(seconds: -1))).inSeconds;

    this._currentDelayVibrationCount = 0;
    this._notificationSec = await notificationLoadSharedPreferences();
    this._vibrationSec = await vibrationLoadSharedPreferences();

    yield TimerRunning(second, startDateTime);

    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: second)
        .listen((second) => add(TimerTicked(second: second, dateTime: startDateTime)));
  }

  Stream<TimerState> _mapTimerTickedToState(TimerTicked tick) async* {
    int second = tick.second;
    DateTime startDateTime = tick.dateTime;
    second = DateTime.now().difference(startDateTime.add(Duration(seconds: -1))).inSeconds;

    await this.doVibration(currentSec: second, notificationSec: this._notificationSec);

    yield TimerRunning(second, startDateTime);

    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: second)
        .listen((second) => add(TimerTicked(second: second, dateTime: startDateTime)));
  }

  Stream<TimerState> _mapTimerResetToState(TimerReset reset) async* {
    _tickerSubscription?.cancel();

    yield TimerReady(0);
  }
}

extension VibrationHelper on TimerBloc {
  Future doVibration({int currentSec, int notificationSec}) async {
    bool isVibration = notificationSec == 0 ? false : currentSec >= notificationSec;
    bool isVibrationing = AppManager().isVibrationing;
    int checkVibrationSec = this._vibrationSec;

    if (isVibrationing || isVibration == false || checkVibrationSec == 0) {
      return;
    }

    if (_currentDelayVibrationCount >= checkVibrationSec) {
      _currentDelayVibrationCount = 0;
    }
    _currentDelayVibrationCount += 1;
    if (_currentDelayVibrationCount != 1) {
      return;
    }

    print("Vibration");

    if (await Vibration.hasVibrator()) {
      AppManager().isVibrationing = true;
      await Vibration.vibrate(duration: 500);
      // await Future.delayed(const Duration(milliseconds: 500), () {});
      AppManager().isVibrationing = false;
    }
  }

  Future<int> notificationLoadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int notificationSecond = (prefs.getInt('NotificationSecond') ?? 0);
    return notificationSecond;
  }

  Future vibrationLoadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int vibrationSecond = (prefs.getInt('VibrationSecond') ?? 0);
    return vibrationSecond;
  }
}
