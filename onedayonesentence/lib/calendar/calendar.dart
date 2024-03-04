import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
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
    final targetKey = normalizeDate(date).millisecondsSinceEpoch;
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

  _getCalendarFormat() {
    return widget.offset <= 100 ? CalendarFormat.month : CalendarFormat.week;
  }

  _getRowHeight() {
    var result = widget.offset <= 100 && widget.offset >= 0
        ? 50 - widget.offset * 0.2
        : 50;
    return result.toDouble();
  }

  _offsetToTargetDate() {
    var result = [];
    for (var date in widget.dateInfos.keys) {
      result.add({
        'date': DateTime.fromMillisecondsSinceEpoch(date),
        'offset': widget.dateInfos[date]['offset']
      });
    }
    return result;
  }

  @override
  void initState() {
    super.initState();

    calendarFormat = _getCalendarFormat();

    rowHeight = _getRowHeight();

    offsetToTargetDate = _offsetToTargetDate();

    focusedDay = offsetToTargetDate.isNotEmpty
        ? _getDateTimeFromOffset(widget.offset.toInt(), 0)
        : DateTime.now();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.offset != oldWidget.offset) {
      calendarFormat = _getCalendarFormat();
      rowHeight = _getRowHeight();

      focusedDay = offsetToTargetDate.isNotEmpty
          ? _getDateTimeFromOffset(widget.offset.toInt(), 0)
          : DateTime.now();
    }

    if (widget.dateInfos != oldWidget.dateInfos) {
      offsetToTargetDate = _offsetToTargetDate();
    }
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
          final targetKey = normalizeDate(selectedDay).millisecondsSinceEpoch;
          if (!isSameDay(focusedDay, selectedDay) &&
              widget.dateInfos.containsKey(targetKey)) {
            widget.scrollToOffset(
                widget.dateInfos[targetKey]['offset'].toDouble());
          }
        },
        onPageChanged: (focusedDay) {
          Provider.of<ContentModel>(context, listen: false)
              .load(focusedDay: focusedDay);
        },
      ),
    );
  }
}
