import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../models/pitch.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? httpClient})
      : _client = httpClient ?? http.Client(),
        baseUrl = const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:4000',
        );

  final http.Client _client;
  final String baseUrl;
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  Future<List<Pitch>> fetchPitches() async {
    final response = await _client.get(_uri('/api/pitches'));
    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Pitch.fromJson)
          .toList(growable: false);
    }

    throw ApiException('Unexpected response format when loading pitches.');
  }

  Future<List<Booking>> fetchBookings({
    String? pitchId,
    DateTime? date,
  }) async {
    final query = <String, String>{};
    if (pitchId != null && pitchId.isNotEmpty) {
      query['pitchId'] = pitchId;
    }
    if (date != null) {
      query['date'] = _dateFormatter.format(date);
    }

    final response = await _client.get(_uri('/api/bookings', query));
    final data = _decodeResponse(response);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Booking.fromJson)
          .toList(growable: false);
    }

    throw ApiException('Unexpected response format when loading bookings.');
  }

  Future<Booking> createBooking({
    required String pitchId,
    required String customerName,
    required String customerPhone,
    required DateTime date,
    required String slot,
  }) async {
    final body = json.encode({
      'pitchId': pitchId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'date': _dateFormatter.format(date),
      'slot': slot,
    });

    final response = await _client.post(
      _uri('/api/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = _decodeResponse(response);
    if (data is Map<String, dynamic>) {
      return Booking.fromJson(data);
    }

    throw ApiException('Unexpected response format when creating booking.');
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$normalizedBase$path').replace(
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    }

    throw ApiException(
      'Request failed with status ${response.statusCode}: ${response.body}',
      response.statusCode,
    );
  }

  void dispose() {
    _client.close();
  }
}
