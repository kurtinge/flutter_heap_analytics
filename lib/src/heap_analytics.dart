import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HeapAnalytics {
  final String apiUrl = 'heapanalytics.com';

  // Heap APP ID
  String? _appId;

  void Function(Object error)? _onError;

  // Provide an instance of the class
  // [appId] is the Heap app id for the current application
  // [identity] is the user identity the will be used to identify the user
  // [errorHandler] add your own error handler.
  HeapAnalytics({required String appId, Function? errorHandler}) {
    _appId = appId;
    _onError = errorHandler as void Function(Object)?;
  }

  Future<bool> track({
    required String event,
    required String identity,
    required Map<String, dynamic> properties,
    DateTime? time,
  }) {

    var eventData = _buildTrackData(
      identity,
      event,
      properties,
      time ?? DateTime.now(),
    );
    String jsonData = json.encode(eventData);
    return _sendTrackEvent(jsonData);
  }

  Future<bool> userProperties({
    required String identity,
    required Map<String, dynamic> properties,
  }) {
    var eventData = _buildUserProperties(identity, properties);
    String jsonData = json.encode(eventData);
    return _sendUserPropertiesEvent(jsonData);
  }

  Map<String, dynamic> _buildTrackData(
    String identity,
    String event,
    Map<String, dynamic> properties,
    DateTime time,
  ) {
    return {
      'app_id': _appId,
      'identity': identity,
      'event': event,
      'timestamp': time.toIso8601String(),
      'properties': properties
    };
  }

  Map<String, dynamic> _buildUserProperties(
    String identity,
    Map<String, dynamic> properties,
  ) {
    return {'app_id': _appId, 'identity': identity, 'properties': properties};
  }

  Future<bool> _sendTrackEvent(String jsonData) =>
      _sendEvent(jsonData, 'track');

  Future<bool> _sendUserPropertiesEvent(String jsonData) =>
      _sendEvent(jsonData, 'add_user_properties');

  Future<bool> _sendEvent(String jsonData, String apiEvent) async {
    final Uri url = Uri.https(apiUrl, '/api/$apiEvent');

    Map<String, String> header = {
      'Content-Type': 'application/json',
    };

    try {
      var response = await http.post(url, headers: header, body: jsonData);

      if (response.statusCode != 200) {
        _onErrorHandler(null,
            'Request to $url failed. Response code: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      _onErrorHandler(e, 'Failed to post to url $url');
      return false;
    }
  }

  void _onErrorHandler(dynamic error, String message) {
    if (_onError != null) {
      _onError!(error ?? message);
    } else {
      debugPrint(message);
    }
  }
}
