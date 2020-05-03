import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HeapAnalytics {
  final String apiUrl = 'https://heapanalytics.com/api';

  // Heap APP ID
  String _appId;

  // User identifier
  // This will be anonyomized in HEAP.
  String _identity;

  void Function(Object error) _onError;

  // Provide an instance of the class
  // [appId] is the Heap app id for the current application
  // [identity] is the user identity the will be used to identify the user
  // [errorHandler] add your own error handler.
  HeapAnalytics(
      {@required String appId,
      @required String identity,
      Function errorHandler}) {
    _appId = appId;
    _identity = identity;
    _onError = errorHandler;
  }

  Future<bool> track({
    @required String event,
    @required Map<String, dynamic> properties,
    DateTime time,
  }) {
    if (event == null) {
      throw ArgumentError.notNull('event');
    }

    if (properties == null) {
      throw ArgumentError.notNull('properties');
    }

    var eventData = _buildTrackData(event, properties, time ?? DateTime.now());
    String jsonData = json.encode(eventData);
    return _sendTrackEvent(jsonData);
  }

  Future<bool> userProperties({@required Map<String, dynamic> properties}) {
    if (properties == null) {
      throw ArgumentError.notNull('properties');
    }
    var eventData = _buildUserProperties(properties);
    String jsonData = json.encode(eventData);
    return _sendUserPropertiesEvent(jsonData);
  }

  Map<String, dynamic> _buildTrackData(
    String event,
    Map<String, dynamic> properties,
    DateTime time,
  ) {
    return {
      'app_id': _appId,
      'identity': _identity,
      'event': event,
      'timestamp': time.toIso8601String(),
      'properties': properties
    };
  }

  Map<String, dynamic> _buildUserProperties(Map<String, dynamic> properties) {
    return {'app_id': _appId, 'identity': _identity, 'properties': properties};
  }

  Future<bool> _sendTrackEvent(String jsonData) =>
      _sendEvent(jsonData, 'track');

  Future<bool> _sendUserPropertiesEvent(String jsonData) =>
      _sendEvent(jsonData, 'add_user_properties');

  Future<bool> _sendEvent(String jsonData, String apiEvent) async {
    String url = '$apiUrl/$apiEvent';

    Map<String, String> header = {
      'Content-Type': 'application/json',
    };

    try {
      var response = await http.post(url, headers: header, body: jsonData);

      debugPrint(response.body);

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
      _onError(error ?? message);
    } else {
      debugPrint(message);
    }
  }
}
