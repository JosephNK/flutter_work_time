import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DateTimeLog extends Equatable {
  final String id;
  final String startDateTime;
  final String endDateTime;

  DateTimeLog({@required this.id, this.startDateTime, this.endDateTime});

  @override
  List<Object> get props => [id, startDateTime, endDateTime];

  @override
  bool get stringify => true;
}
