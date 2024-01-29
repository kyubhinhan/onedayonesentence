import 'package:flutter/material.dart';
import 'calender/calender.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'form/content_form.dart';
import 'api.dart';
import 'layout/content_items.dart';

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
  DateTime selectedDate = DateTime.now();
  late final ScrollController _controller;
  Future dateContents = Future(() => null);
  List offsetToTargetDate = [];
  double _rowHeight = 60;

  loadContents(DateTime date) async {
    List? contents = await getContents(date);

    var dateContent = {};
    var offsetDate = [];
    var offset = 0;

    if (contents == null) {
      setState(() {
        dateContents = Future(() => null);
        offsetToTargetDate = [];
      });
      return;
    }

    for (var content in contents) {
      var targetDate =
          normalizeDate(DateTime.fromMillisecondsSinceEpoch(content['date']));
      if (dateContent.containsKey(targetDate)) {
        dateContent[targetDate].add(content);
        final ofDate =
            offsetDate.firstWhere((element) => element['date'] == targetDate);
        ofDate['itemCount'] = ofDate['itemCount'] + 1;
      } else {
        dateContent[targetDate] = [content];
        offsetDate.add({'offset': offset, 'date': targetDate, 'itemCount': 1});

        offset += 500;
      }
    }

    setState(() {
      dateContents = Future(() => dateContent);
      offsetToTargetDate = List.from(offsetDate);
    });
  }

  selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _controller.addListener(_handleControllerOffset);

    loadContents(DateTime.now());
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerOffset);
    super.dispose();
  }

  void _handleControllerOffset() {
    if (_controller.offset < 100) {
      setState(() {
        showMonth = true;
        if (_controller.offset >= 0) {
          _rowHeight = 60 - _controller.offset * 0.3;
        }
      });
    } else {
      setState(() {
        showMonth = false;
        _rowHeight = 60;
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
                      expandedHeight: 400,
                      collapsedHeight: 150,
                      flexibleSpace: Column(
                        children: [
                          Expanded(
                            child: Calender(
                              showMonth: showMonth,
                              targetDates: {
                                for (var item in offsetToTargetDate)
                                  item['date']: item
                              },
                              controller: _controller,
                              selectedDate: selectedDate,
                              loadContents: loadContents,
                              selectDate: selectDate,
                              rowHeight: _rowHeight,
                            ),
                          ),
                        ],
                      )),
                  SliverFixedExtentList(
                    itemExtent: 500.0,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (snapshot.data.length > index) {
                          final targetKey = snapshot.data.keys.toList()[index];
                          return ContentItems(
                              loadContents: loadContents,
                              contents: snapshot.data[targetKey]);
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

                  loadContents(DateTime.now());
                },
                tooltip: 'Add Sentence',
                child: const Icon(Icons.add),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }
}
