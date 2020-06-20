part of 'timer_bloc.dart';

@immutable
abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStarted extends TimerEvent {
  final int second;

  TimerStarted({@required this.second});

  // @override
  // String toString() => "TimerStarted { second: $second }";
}

class TimerReset extends TimerEvent {
  final int second;

  TimerReset({@required this.second});

  // @override
  // String toString() => "TimerReset { second: $second }";
}

class TimerTicked extends TimerEvent {
  final int second;
  final int notiSecond;
  final int vibraSecond;
  final DateTime dateTime;

  TimerTicked({@required this.second, this.notiSecond, this.vibraSecond, this.dateTime});

  @override
  List<Object> get props => [second, notiSecond, dateTime];

  // @override
  // String toString() => "Tick { second: $second }";
}
