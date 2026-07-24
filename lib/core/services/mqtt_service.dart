import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  final String broker;
  final int port;
  final String clientIdentifier;

  MqttService({
    required this.broker,
    required this.port,
    required this.clientIdentifier,
  });

  Future<void> connect() async {
    client = MqttServerClient(broker, clientIdentifier);
    client.port = port;
    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client.updates;
  }

  void onConnected() {
    debugPrint('MQTT Connected');
  }

  void onDisconnected() {
    debugPrint('MQTT Disconnected');
  }

  void onSubscribed(String topic) {
    debugPrint('MQTT Subscribed to $topic');
  }
}
