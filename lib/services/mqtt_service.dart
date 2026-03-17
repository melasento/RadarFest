import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../models/pin.dart';

typedef FriendUpdateCallback = void Function(Friend friend);
typedef PinUpdateCallback = void Function(Pin pin);
typedef PinDeleteCallback = void Function(String pinId);
typedef SosCallback = void Function(String senderId, String senderName);
typedef ConnectionCallback = void Function(bool connected);

class MqttService {
  static const String _broker = 'wss://x5aa8213.ala.eu-central-1.emqxsl.com';
  static const int _port = 8084;
  static const String _username = 'melasento';
  static const String _password = 'Rfmqtt2024!';

  MqttServerClient? _client;
  String? _groupId;
  String? _userId;
  Timer? _publishTimer;
  bool _connected = false;

  FriendUpdateCallback? onFriendUpdate;
  PinUpdateCallback? onPinUpdate;
  PinDeleteCallback? onPinDelete;
  SosCallback? onSos;
  ConnectionCallback? onConnectionChanged;

  bool get isConnected => _connected;

  Future<void> connect({
    required String groupId,
    required String userId,
  }) async {
    _groupId = groupId;
    _userId = userId;

    final clientId = 'flutter_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient.withPort(_broker, clientId, _port);
    _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    _client!.useWebSocket = true;
    _client!.secure = true;
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onAutoReconnect = () => print('MQTT auto-reconnecting...');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(_username, _password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      print('MQTT connect error: $e');
      _client!.disconnect();
    }
  }

  void _onConnected() {
    _connected = true;
    onConnectionChanged?.call(true);
    _subscribeToTopics();
    _client!.updates!.listen(_onMessage);
  }

  void _onDisconnected() {
    _connected = false;
    onConnectionChanged?.call(false);
  }

  void _subscribeToTopics() {
    if (_groupId == null) return;
    final topics = [
      'radarfest/$_groupId/locations',
      'radarfest/$_groupId/pins',
      'radarfest/$_groupId/sos',
    ];
    for (final topic in topics) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
          (msg.payload as MqttPublishMessage).payload.message);
      try {
        final data = json.decode(payload) as Map<String, dynamic>;
        if (topic.endsWith('/locations')) {
          final friend = Friend.fromJson(data);
          if (friend.id != _userId) {
            onFriendUpdate?.call(friend);
          }
        } else if (topic.endsWith('/pins')) {
          if (data['action'] == 'delete') {
            onPinDelete?.call(data['id'] as String);
          } else {
            onPinUpdate?.call(Pin.fromJson(data));
          }
        } else if (topic.endsWith('/sos')) {
          onSos?.call(data['senderId'] as String, data['senderName'] as String);
        }
      } catch (e) {
        print('MQTT parse error: $e');
      }
    }
  }

  void publishLocation(Friend me) {
    if (!_connected || _groupId == null) return;
    final topic = 'radarfest/$_groupId/locations';
    _publish(topic, json.encode(me.toJson()));
  }

  void publishPin(Pin pin) {
    if (!_connected || _groupId == null) return;
    final topic = 'radarfest/$_groupId/pins';
    _publish(topic, json.encode(pin.toJson()));
  }

  void publishPinDelete(String pinId) {
    if (!_connected || _groupId == null) return;
    final topic = 'radarfest/$_groupId/pins';
    _publish(topic, json.encode({'action': 'delete', 'id': pinId}));
  }

  void publishSos(String userId, String userName) {
    if (!_connected || _groupId == null) return;
    final topic = 'radarfest/$_groupId/sos';
    _publish(topic, json.encode({'senderId': userId, 'senderName': userName}));
  }

  void _publish(String topic, String payload) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void startLocationBroadcast(Friend Function() getFriend, {int intervalSeconds = 5}) {
    _publishTimer?.cancel();
    _publishTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => publishLocation(getFriend()),
    );
  }

  void stopLocationBroadcast() {
    _publishTimer?.cancel();
    _publishTimer = null;
  }

  void disconnect() {
    stopLocationBroadcast();
    _client?.disconnect();
    _connected = false;
  }
}
