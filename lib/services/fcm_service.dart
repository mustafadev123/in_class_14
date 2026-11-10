import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/payload_result.dart';

class FCMService extends ChangeNotifier {
  FCMService([this._messaging]);

  FirebaseMessaging? _messaging;
  FirebaseMessaging get _messagingInstance =>
      _messaging ??= FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenSubscription;

  CampusAsset _asset = CampusAsset.defaultCampus;
  String _title = 'Campus updates';
  String _diagnostic = 'Waiting for a cloud message.';
  String _lastHandler = 'None yet';
  String? _messageId;
  AuthorizationStatus? _authorizationStatus;
  bool _tokenAvailable = false;
  String? _token;
  int _receiptCount = 0;
  bool _initialized = false;
  bool _disposed = false;

  CampusAsset get asset => _asset;
  String get title => _title;
  String get diagnostic => _diagnostic;
  String get lastHandler => _lastHandler;
  String? get messageId => _messageId;
  AuthorizationStatus? get authorizationStatus => _authorizationStatus;
  bool get tokenAvailable => _tokenAvailable;
  String? get token => _token;
  int get receiptCount => _receiptCount;

  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    _initialized = true;

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (message) => _handleMessage(message, 'onMessage'),
    );
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleMessage(message, 'onMessageOpenedApp'),
    );
    _tokenSubscription = _messagingInstance.onTokenRefresh.listen((token) {
      if (_disposed) return;
      _token = token;
      _tokenAvailable = token.isNotEmpty;
      notifyListeners();
    });

    try {
      final settings = await _messagingInstance.requestPermission();
      if (_disposed) return;
      _authorizationStatus = settings.authorizationStatus;
    } on FirebaseException catch (error) {
      _diagnostic = 'Permission check failed: ${error.code}.';
    }

    try {
      final token = await _messagingInstance.getToken();
      if (_disposed) return;
      _token = token;
      _tokenAvailable = token != null;
    } on FirebaseException catch (error) {
      _diagnostic = 'Token check failed: ${error.code}.';
    }

    RemoteMessage? initialMessage;
    try {
      initialMessage = await _messagingInstance.getInitialMessage();
    } on FirebaseException catch (error) {
      _diagnostic = 'Initial-message check failed: ${error.code}.';
    }
    if (_disposed) return;
    if (initialMessage != null) {
      _handleMessage(initialMessage, 'getInitialMessage');
    } else {
      notifyListeners();
    }
  }

  void _handleMessage(RemoteMessage message, String handler) {
    if (_disposed) return;

    _receiptCount += 1;
    _lastHandler = handler;
    _messageId = message.messageId;

    switch (validatePayload(message.data)) {
      case ValidPayload(:final asset):
        _asset = asset;
        _title = message.notification?.title ?? 'Campus update';
        _diagnostic = 'Accepted ${asset.payloadValue} campus update.';
      case InvalidPayload(:final reason):
        _diagnostic = reason;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedAppSubscription?.cancel());
    unawaited(_tokenSubscription?.cancel());
    super.dispose();
  }
}
