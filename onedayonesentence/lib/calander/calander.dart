import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calander extends StatefulWidget {
  final bool showMonth;

  const Calander({super.key, required this.showMonth});

  @override
  State<Calander> createState() => _CalanderState();
}

class _CalanderState extends State<Calander> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
      focusedDay: _focusedDay,
      calendarFormat: calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          // Call `setState()` when updating the selected day
          setState(() {
            _selectedDay = selectedDay;
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
