import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api.dart';
import '../layout/content_items.dart';
import '../calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import '../form/content_form.dart';

class ContentModel extends ChangeNotifier {
  Future _contents = getContents(DateTime.now());

  Future get contents => _contents;

  void load({DateTime? focusedDay}) {
    _contents = getContents(focusedDay ?? DateTime.now());
    notifyListeners(); // 상태 변경을 Provider에 알림
  }
}

class MyContentProvider extends StatelessWidget {
  const MyContentProvider({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ContentModel(), child: MyHomePage(title: title));
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
        body: Consumer<ContentModel>(
          builder: (context, value, child) =>
              MyFutureBuilder(contents: value.contents),
        ),
        bottomNavigationBar: MyBottomNavigationBar(
            currentPageIndex: currentPageIndex,
            setPageIndex: (index) => {setState(index)}),
        floatingActionButton:
            currentPageIndex == 0 ? const MyFloatingActionButton() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }
}

class MyFutureBuilder extends StatelessWidget {
  const MyFutureBuilder({super.key, required this.contents});

  final Future contents;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: contents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyCustomScrollView(contents: snapshot.data ?? []);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class MyCustomScrollView extends StatefulWidget {
  const MyCustomScrollView({super.key, required this.contents});

  final List contents;

  @override
  State<MyCustomScrollView> createState() => _MyCustomScrollView();
}

class _MyCustomScrollView extends State<MyCustomScrollView> {
  double offset = 0;
  late Map dateInfos;
  final ScrollController _controller = ScrollController();

  Map _getDateInfos(List contents) {
    var result = {};
    var offset = 0;

    for (var content in contents) {
      var targetDt =
          normalizeDate(DateTime.fromMillisecondsSinceEpoch(content['date']))
              .millisecondsSinceEpoch;
      if (result.containsKey(targetDt)) {
        result[targetDt]['count'] += 1;
      } else {
        offset += 500;
        result[targetDt] = {'count': 1, 'offset': offset};
      }
    }

    return result;
  }

  _loadOffset() {
    setState(() {
      offset = _controller.offset;
    });
  }

  scrollToOffset(double offset) {
    _controller.position.animateTo(offset,
        duration: const Duration(seconds: 1),
        curve: const Cubic(0.25, 0.1, 0.25, 1.0));
  }

  @override
  void initState() {
    super.initState();

    dateInfos = _getDateInfos(widget.contents);
    _controller.addListener(_loadOffset);
  }

  @override
  void didUpdateWidget(MyCustomScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 외부 prop이 변경되었는지 확인
    if (widget.contents != oldWidget.contents) {
      // 변경된 경우, 내부 state 업데이트
      dateInfos = _getDateInfos(widget.contents);
      _controller.addListener(_loadOffset);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_loadOffset);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
            pinned: true,
            expandedHeight: 400,
            collapsedHeight: 150,
            flexibleSpace: Column(
              children: [
                Expanded(
                  child: Calendar(
                    offset: offset,
                    dateInfos: dateInfos,
                    scrollToOffset: scrollToOffset,
                  ),
                ),
              ],
            )),
        MySliverFixedExtentList(contents: widget.contents)
      ],
      controller: _controller,
    );
  }
}

class MySliverFixedExtentList extends StatefulWidget {
  const MySliverFixedExtentList({super.key, required this.contents});

  final List contents;

  @override
  State<MySliverFixedExtentList> createState() => _MySliverFixedExtentList();
}

class _MySliverFixedExtentList extends State<MySliverFixedExtentList> {
  late Map dateContents;

  getDateContents() {
    var result = {};
    for (var content in widget.contents) {
      var targetDt =
          normalizeDate(DateTime.fromMillisecondsSinceEpoch(content['date']))
              .millisecondsSinceEpoch;
      if (result.containsKey(targetDt)) {
        result[targetDt].add(content);
      } else {
        result[targetDt] = [content];
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();

    dateContents = getDateContents();
  }

  @override
  void didUpdateWidget(MySliverFixedExtentList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.contents != oldWidget.contents) {
      dateContents = getDateContents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: 500.0,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (dateContents.length > index) {
            final targetKey = dateContents.keys.toList()[index];
            return ContentItems(contents: dateContents[targetKey]);
          }
        },
      ),
    );
  }
}

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar(
      {super.key, required this.currentPageIndex, required this.setPageIndex});

  final int currentPageIndex;
  final Function setPageIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setPageIndex(index);
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
    );
  }
}

class MyFloatingActionButton extends StatefulWidget {
  const MyFloatingActionButton({super.key});

  @override
  State<MyFloatingActionButton> createState() => _MyFloatingActionButton();
}

class _MyFloatingActionButton extends State<MyFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(context, MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return const ContentForm();
          },
        ));

        if (!mounted) return;

        Provider.of<ContentModel>(context, listen: false)
            .load(focusedDay: DateTime.now());
      },
      tooltip: 'Add Sentence',
      child: const Icon(Icons.add),
    );
  }
}
