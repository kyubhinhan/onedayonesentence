import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../src/my_home_page.dart';

class Calendar extends StatefulWidget {
  const Calendar(
      {super.key,
      required this.offset,
      required this.dateInfos,
      required this.scrollToOffset});

  final double offset;
  final Map dateInfos;
  final Function scrollToOffset;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late CalendarFormat calendarFormat;
  late double rowHeight;
  late List offsetToTargetDate;
  DateTime focusedDay = DateTime.now();

  List _eventLoader(DateTime date) {
    final targetKey = normalizeDate(date);
    if (widget.dateInfos.containsKey(targetKey)) {
      return List.generate(
          widget.dateInfos[targetKey]['count'], (index) => index);
    } else {
      return [];
    }
  }

  DateTime _getDateTimeFromOffset(int offset, int index) {
    if (offsetToTargetDate[index]['offset'] == offset) {
      return offsetToTargetDate[index]['date'];
    } else if (offsetToTargetDate[index]['offset'] > offset) {
      if (index == 0 || offsetToTargetDate[index - 1]['offset'] < offset) {
        return offsetToTargetDate[index]['date'];
      } else {
        return _getDateTimeFromOffset(offset, index - 1);
      }
    } else {
      if (index == offsetToTargetDate.length - 1 ||
          offsetToTargetDate[index + 1]['offset'] > offset) {
        return offsetToTargetDate[index]['date'];
      } else {
        return _getDateTimeFromOffset(offset, index + 1);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    calendarFormat =
        widget.offset <= 0 ? CalendarFormat.month : CalendarFormat.week;

    rowHeight = widget.offset < 100 ? 50 - widget.offset * 0.2 : 50;

    offsetToTargetDate = (() {
      const result = [];
      for (var date in widget.dateInfos.keys) {
        result.add({'date': date, 'offset': widget.dateInfos[date]['offset']});
      }
      return result;
    })();

    focusedDay = _getDateTimeFromOffset(widget.offset.toInt(), 0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: TableCalendar(
        sixWeekMonthsEnforced: true,
        locale: 'ko_KR',
        rowHeight: rowHeight,
        headerStyle:
            const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        firstDay: DateTime.utc(2023, 10, 01),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        eventLoader: _eventLoader,
        selectedDayPredicate: (day) {
          return isSameDay(focusedDay, day);
        },
        onDaySelected: (selectedDay, _) {
          final targetKey = normalizeDate(selectedDay);
          if (!isSameDay(focusedDay, selectedDay) &&
              widget.dateInfos.containsKey(targetKey)) {
            widget.scrollToOffset(
                widget.dateInfos[targetKey]['offset'].toDouble(),
                duration: const Duration(seconds: 1),
                curve: const Cubic(0.25, 0.1, 0.25, 1.0));
          }
        },
        onPageChanged: (focusedDay) {
          MyInheritedWidget.of(context).loadContents(focusedDay);
        },
      ),
    );
  }
}
