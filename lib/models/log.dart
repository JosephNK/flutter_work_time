import 'package:equatable/equatable.dart';

class DateTimeLog extends Equatable {
  final int id;
  final String startDateTime;
  final String endDateTime;

  DateTimeLog({this.id, this.startDateTime, this.endDateTime});

  @override
  List<Object> get props => [id, startDateTime, endDateTime];

  @override
  bool get stringify => true;
}
