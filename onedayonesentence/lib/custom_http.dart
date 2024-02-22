import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';

class CustomHttp {
  CustomHttp();

  static const baseUrl = 'localhost:3000';

  static final CustomHttp instance = CustomHttp();

  Future<String> getAccessToken() async {
    try {
      // accessToken의 발급 및 갱신을 위해 한 번 불러줌
      await UserApi.instance.accessTokenInfo();

      OAuthToken? oAutoToken =
          await TokenManagerProvider.instance.manager.getToken();

      return oAutoToken?.accessToken ?? "";
    } catch (e) {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      OAuthToken? oAutoToken =
          await TokenManagerProvider.instance.manager.getToken();

      return oAutoToken?.accessToken ?? "";
    }
  }

  get(url, Map<String, dynamic> params) async {
    String accessToken = await getAccessToken();

    try {
      http.Response response = await http.get(Uri.http(baseUrl, url, params),
          headers: {'Authorization': 'Bearer $accessToken'});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return jsonData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  post(url, body) async {
    String accessToken = await getAccessToken();

    return http.post(
      Uri.http(baseUrl, url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: body,
    );
  }

  put(url, body) async {
    String accessToken = await getAccessToken();

    return http.put(
      Uri.http(baseUrl, url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: body,
    );
  }

  delete(url, Map<String, dynamic> params) async {
    String accessToken = await getAccessToken();

    return http.delete(Uri.http(baseUrl, url, params),
        headers: {'Authorization': 'Bearer $accessToken'});
  }
}
