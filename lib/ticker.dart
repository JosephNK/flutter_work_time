//
// https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb
//
class Ticker {
  // Stream<int> tick({int ticks}) {
  //   return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1).take(ticks);
  // }
  Stream<int> tick({int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (x) => ticks + 1);
  }
}
