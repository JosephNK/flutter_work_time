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
  final DateTime dateTime;

  TimerTicked({@required this.second, this.dateTime});

  @override
  List<Object> get props => [second, dateTime];

  // @override
  // String toString() => "Tick { second: $second }";
}
