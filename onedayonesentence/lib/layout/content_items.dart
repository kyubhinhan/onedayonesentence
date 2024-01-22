import 'package:flutter/material.dart';
import '../form/content_form.dart';

class ContentItems extends StatefulWidget {
  const ContentItems(
      {super.key, required this.contents, required this.loadContents});

  final List contents;
  final Function loadContents;

  @override
  State<ContentItems> createState() => _ContentItemsState();
}

class _ContentItemsState extends State<ContentItems> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        itemCount: widget.contents.length,
        itemBuilder: (context, index) {
          var content = widget.contents[index];

          return Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(getDateFromDateTime(
                        DateTime.fromMillisecondsSinceEpoch(content['date']))),
                  ),
                  ListTile(
                    title: Text(content['title']),
                    subtitle: Text(content['author']),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20)),
                    height: 300,
                    child: Center(
                        child: Text(
                      content['impression'],
                      style: const TextStyle(color: Colors.white70),
                    )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 40))),
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return ContentForm(
                            id: content['id'],
                            title: content['title'],
                            author: content['author'],
                            date: DateTime.fromMillisecondsSinceEpoch(
                                content['date']),
                            impression: content['impression'],
                            mode: "edit",
                          );
                        },
                      ));

                      widget.loadContents(DateTime.now());
                    },
                    child: const Text('수정'),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
