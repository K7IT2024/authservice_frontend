import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {

  static const FlutterSecureStorage storage =
      FlutterSecureStorage();

 static Future<void> saveTokens({

  required String accessToken,

  required String refreshToken,

}) async {

  await storage.write(
    key: "accessToken",
    value: accessToken,
  );

  await storage.write(
    key: "refreshToken",
    value: refreshToken,
  );

}

  static Future<String?> getAccessToken() async {

    return await storage.read(
      key: "accessToken",
    );
  }

 static Future<String?> getRefreshToken() async {
    return await storage.read(key: "refreshToken");
  }
  static Future<void> clear() async {

    await storage.deleteAll();

  }

}