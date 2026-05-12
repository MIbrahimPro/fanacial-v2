import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String apiSecret = 'mm-sync-secret-k7F9xP2q';

  final String baseUrl;

  ApiService(this.baseUrl);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiSecret',
      };

  Future<Map<String, dynamic>> sync({
    String? lastSync,
    Map<String, List<Map<String, dynamic>>>? records,
  }) async {
    final uri = Uri.parse('$baseUrl/api/sync');
    final body = <String, dynamic>{};
    if (lastSync != null) body['last_sync'] = lastSync;
    if (records != null) body['records'] = records;

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw ApiException('Network error: $e');
    }

    if (response.statusCode == 401) {
      throw ApiException('Unauthorized — sync token invalid');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (!(data['success'] as bool? ?? false)) {
      throw ApiException(data['error'] as String? ?? 'Unknown error');
    }
    return data;
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
