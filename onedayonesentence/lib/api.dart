import 'dart:convert';
import 'custom_http.dart';

Future<List?> getContents(DateTime date) async {
  int time = date.millisecondsSinceEpoch;
  String url = 'content';

  return CustomHttp.instance.get(url, {'dt': time});
}

addContent(title, author, date, impression) {
  String url = 'content';

  Map<String, dynamic> jsonData = {
    'title': title,
    'author': author,
    'date': date,
    'impression': impression
  };

  String jsonBody = json.encode(jsonData);

  return CustomHttp.instance.post(url, jsonBody);
}

editContent(id, title, author, date, impression) {
  String url = 'content';

  Map<String, dynamic> jsonData = {
    'id': id,
    'title': title,
    'author': author,
    'date': date,
    'impression': impression
  };

  String jsonBody = json.encode(jsonData);

  return CustomHttp.instance.put(url, jsonBody);
}

deleteContent(id) {
  String url = 'content';

  return CustomHttp.instance.delete(url, {id: id});
}
