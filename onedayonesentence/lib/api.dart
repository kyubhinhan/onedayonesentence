import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List?> getContents(DateTime date) async {
  int time = date.millisecondsSinceEpoch;
  String apiUrl = 'http://localhost:3000/content?dt=$time';

  try {
    // GET 요청 보내기
    http.Response response = await http.get(Uri.parse(apiUrl));

    // HTTP 상태코드 확인 (예: 200은 성공)
    if (response.statusCode == 200) {
      // JSON 데이터로 변환 예제
      List jsonData = json.decode(response.body);
      return jsonData;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

addContent(title, author, date, impression) {
  Uri apiUrl = Uri.parse('http://localhost:3000/content');

  Map<String, dynamic> jsonData = {
    'title': title,
    'author': author,
    'date': date,
    'impression': impression
  };

  String jsonBody = json.encode(jsonData);

  http.post(
    apiUrl,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonBody,
  );
}
