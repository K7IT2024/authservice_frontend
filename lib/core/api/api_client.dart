import 'dart:convert';

import 'package:auth_flutter/core/storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {

  static Future<http.Response> post(

      String url,

      Map<String, dynamic> body) async {

    return await http.post(

      Uri.parse(url),

      headers: {

        "Content-Type": "application/json",

      },

      body: jsonEncode(body),

    );

  }
  static Future<http.Response> get(
    String endpoint) async {

  final token = await SecureStorageService.getAccessToken();

  return await http.get(

    Uri.parse(endpoint),

    headers: {

      "Content-Type": "application/json",

      if (token != null)
        "Authorization": "Bearer $token",

    },

  );

}

}