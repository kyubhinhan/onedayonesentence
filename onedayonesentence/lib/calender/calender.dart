import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  final bool showMonth;
  final Map targetDates;
  final ScrollController controller;
  final DateTime selectedDate;

  const Calender(
      {super.key,
      required this.showMonth,
      required this.targetDates,
      required this.controller,
      required this.selectedDate});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _focusedDay = DateTime.now();

  List _eventLoader(DateTime date) {
    final targetKey = normalizeDate(date);
    if (widget.targetDates.containsKey(targetKey)) {
      return ['hi'];
    } else {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final calendarFormat =
        widget.showMonth ? CalendarFormat.month : CalendarFormat.week;

    return TableCalendar(
      locale: 'ko_KR',
      daysOfWeekHeight: 20,
      headerStyle:
          const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      firstDay: DateTime.utc(2023, 10, 01),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: widget.selectedDate,
      calendarFormat: calendarFormat,
      eventLoader: _eventLoader,
      selectedDayPredicate: (day) {
        return isSameDay(widget.selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(widget.selectedDate, selectedDay)) {
          final targetKey = normalizeDate(selectedDay);

          widget.controller.position.animateTo(
              widget.targetDates[targetKey]['offset'].toDouble(),
              duration: const Duration(seconds: 1),
              curve: const Cubic(0.25, 0.1, 0.25, 1.0));

          // Call `setState()` when updating the selected day
          setState(() {
            _focusedDay = focusedDay;
          });
        }
      },
      onPageChanged: (focusedDay) {
        // No need to call `setState()` here
        _focusedDay = focusedDay;
      },
    );
  }
}
