part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int second;
  final int notiSecond;
  final int vibraSecond;
  final DateTime startDateTime;

  TimerState(this.second, this.notiSecond, this.vibraSecond, this.startDateTime);

  @override
  List<Object> get props => [second];
}

class TimerReady extends TimerState {
  TimerReady(int second) : super(second, 0, 0, null);

  // @override
  // String toString() => 'TimerReady { second: $second }';
}

class TimerRunning extends TimerState {
  TimerRunning(int second, int notiSecond, int vibraSecond, DateTime startDateTime) : super(second, notiSecond, vibraSecond, startDateTime);

  // @override
  // String toString() => 'TimerRunning { second: $second }';
}

class TimerFinished extends TimerState {
  TimerFinished(int second) : super(second, 0, 0, null);

  // @override
  // String toString() => 'TimerFinished { second: $second }';
}
