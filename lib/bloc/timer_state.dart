part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int second;
  final DateTime startDateTime;

  TimerState(this.second, this.startDateTime);

  @override
  List<Object> get props => [second];
}

class TimerReady extends TimerState {
  TimerReady(int second) : super(second, null);

  // @override
  // String toString() => 'TimerReady { second: $second }';
}

class TimerRunning extends TimerState {
  TimerRunning(int second, DateTime startDateTime) : super(second, startDateTime);

  // @override
  // String toString() => 'TimerRunning { second: $second }';
}

class TimerFinished extends TimerState {
  TimerFinished(int second) : super(second, null);

  // @override
  // String toString() => 'TimerFinished { second: $second }';
}
