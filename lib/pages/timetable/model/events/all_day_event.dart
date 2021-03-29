import 'package:flutter/material.dart';
import 'package:student_hub_demo/pages/classes/model/class.dart';
import 'package:student_hub_demo/pages/timetable/model/academic_calendar.dart';
import 'package:student_hub_demo/pages/timetable/model/events/uni_event.dart';
import 'package:time_machine/time_machine.dart';

class AllDayUniEvent extends UniEvent {
  AllDayUniEvent({
    @required LocalDate start,
    @required LocalDate end,
    @required String id,
    String name,
    String location,
    Color color,
    UniEventType type,
    ClassHeader classHeader,
    AcademicCalendar calendar,
    List<String> relevance,
    String degree,
    String addedBy,
  })  : startDate = start,
        endDate = end,
        super(
            name: name,
            location: location,
            start: start.atMidnight(),
            duration: Period.differenceBetweenDates(start, end.addDays(1)),
            id: id,
            color: color,
            type: type,
            classHeader: classHeader,
            calendar: calendar,
            relevance: relevance,
            degree: degree,
            addedBy: addedBy);

  LocalDate startDate;
  LocalDate endDate;

  @override
  Iterable<UniEventInstance> generateInstances(
      {DateInterval intersectingInterval}) sync* {
    yield UniEventInstance(
      id: id,
      title: name,
      mainEvent: this,
      start: startDate.atMidnight(),
      end: endDate.addDays(1).atMidnight(),
      color: color,
    );
  }
}
