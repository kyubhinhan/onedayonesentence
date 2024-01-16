import 'package:flutter/material.dart';
import 'calender/calender.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'form/content_form.dart';
import 'api.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title Change',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'custom scrollview test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  bool showMonth = true;
  List offsetToTargetDate = [];
  DateTime selectedDate = DateTime.now();
  late final ScrollController _controller;
  Future dateContents = Future(() => null);

  Future getTotalDates(DateTime date) async {
    List? dates = await getContents(date);

    var obj = {};
    var offset = -50;
    offsetToTargetDate = [];

    if (dates == null) {
      return obj;
    }

    for (var date in dates) {
      var targetDate =
          normalizeDate(DateTime.fromMillisecondsSinceEpoch(date['date']));
      if (obj.containsKey(targetDate)) {
        obj[targetDate]['dates'].add(date);
      } else {
        offset = offset + 300;
        offsetToTargetDate.add({'offset': offset, 'date': targetDate});
        obj[targetDate] = {
          'date': targetDate,
          'dates': [date],
          'offset': offset,
        };
      }
    }

    return obj;
  }

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _controller.addListener(_handleControllerOffset);
    dateContents = getTotalDates(DateTime.now());
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerOffset);
    super.dispose();
  }

  void _handleControllerOffset() {
    if (_controller.offset > 0) {
      setState(() {
        showMonth = false;
      });
    } else {
      setState(() {
        showMonth = true;
      });
    }

    var targetDate = _getDateTimeFromOffset(_controller.offset.toInt(), 0);
    if (selectedDate != targetDate) {
      setState(() {
        selectedDate = targetDate;
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.supervised_user_circle),
                tooltip: 'User',
                onPressed: () {},
              ),
            ]),
        body: FutureBuilder(
          future: dateContents,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                      pinned: true,
                      expandedHeight: 450,
                      collapsedHeight: 150,
                      flexibleSpace: Calender(
                        showMonth: showMonth,
                        targetDates: snapshot.data,
                        controller: _controller,
                        selectedDate: selectedDate,
                      )),
                  SliverFixedExtentList(
                    itemExtent: 350.0,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (snapshot.data.length > index) {
                          final targetKey = snapshot.data.keys.toList()[index];
                          return Container(
                            alignment: Alignment.center,
                            color: Colors.indigo[100 * ((index + 1) % 9)],
                            child: Text(
                                'Time is ${snapshot.data[targetKey]['date']}'),
                          );
                        }
                      },
                    ),
                  )
                ],
                controller: _controller,
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Colors.amber,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.person_2),
              icon: Icon(Icons.person_2_outlined),
              label: 'Individual',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.people),
              icon: Icon(Icons.people_outlined),
              label: 'Community',
            ),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
        floatingActionButton: currentPageIndex == 0
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const ContentForm();
                    },
                  ));

                  setState(() {
                    dateContents = getTotalDates(DateTime.now());
                  });
                },
                tooltip: 'Add Sentence',
                child: const Icon(Icons.add),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }
}
