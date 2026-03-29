import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttService();

  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  MqttServerClient? _client;

  Stream<String> get messages => _messageController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  Future<bool> connect({
    required String broker,
    required String topic,
    required String clientId,
  }) async {
    final url = _parseBroker(broker);
    final client = MqttServerClient(url.host, clientId);
    client.port = url.port;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = () {
      _connectionController.add(false);
    };
    client.onConnected = () {
      _connectionController.add(true);
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (_) {
      _connectionController.add(false);
      client.disconnect();
      return false;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      _connectionController.add(false);
      client.disconnect();
      return false;
    }

    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates?.listen((messages) {
      final payload = _extractPayload(messages);
      if (payload != null) {
        _messageController.add(payload);
      }
    });

    _client = client;
    _connectionController.add(true);
    return true;
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }

  Uri _parseBroker(String broker) {
    final raw = broker.trim();
    if (raw.contains('://')) {
      final url = Uri.parse(raw);
      return url.hasPort
          ? url
          : url.replace(port: 1883);
    }

    final url = Uri.parse('mqtt://$raw');
    return url.hasPort ? url : url.replace(port: 1883);
  }

  String? _extractPayload(
    List<MqttReceivedMessage<MqttMessage>> messages,
  ) {
    if (messages.isEmpty) {
      return null;
    }
    final recMess = messages.first.payload;
    if (recMess is! MqttPublishMessage) {
      return null;
    }
    return MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
  }
}
