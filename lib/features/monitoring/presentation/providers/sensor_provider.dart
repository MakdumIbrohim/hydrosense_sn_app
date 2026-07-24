import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../../../core/services/mqtt_service.dart';
import '../../domain/entities/sensor_data.dart';

class SensorProvider extends ChangeNotifier {
  SensorData? _currentData;
  final Random _random = Random();
  bool _isLoading = true;
  late final MqttService _mqttService;
  StreamSubscription? _mqttSubscription;

  SensorData? get currentData => _currentData;
  bool get isLoading => _isLoading;

  SensorProvider() {
    _mqttService = MqttService(
      broker: 'broker.emqx.io', 
      port: 1883, 
      clientIdentifier: 'hydrosense_app_${DateTime.now().millisecondsSinceEpoch}',
    );
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    _generateDummyData(); // Data awal
    notifyListeners();

    await _mqttService.connect();
    _isLoading = false;
    notifyListeners();

    _mqttService.subscribe('hydrosense/sensor_data'); // Topik ESP32
    
    final stream = _mqttService.getMessagesStream();
    if (stream != null) {
      _mqttSubscription = stream.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        debugPrint('MQTT Terima: $payload');
        _handleMqttMessage(payload);
      });
    }
  }

  void _handleMqttMessage(String payload) {
    try {
      // Format JSON dari ESP32: {"ph": 6.8, "tds": 550, "ec": 1.2, "temp": 26.5, "vol": 75.0, "n": 10, "p": 5, "k": 15}
      final data = jsonDecode(payload);
      _currentData = SensorData(
        ph: (data['ph'] ?? 0.0).toDouble(),
        tds: (data['tds'] ?? 0.0).toDouble(),
        ec: (data['ec'] ?? 0.0).toDouble(),
        waterTemperature: (data['temp'] ?? 0.0).toDouble(),
        waterVolume: (data['vol'] ?? 0.0).toDouble(),
        npk: NpkData(
          nitrogen: (data['n'] ?? 0.0).toDouble(),
          phosphorus: (data['p'] ?? 0.0).toDouble(),
          potassium: (data['k'] ?? 0.0).toDouble(),
        ),
        timestamp: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error parse JSON MQTT: $e');
    }
  }

  void _generateDummyData() {
    _currentData = SensorData(
      ph: 6.0 + _random.nextDouble() * 1.5,
      tds: 500 + _random.nextDouble() * 300,
      ec: 1.0 + _random.nextDouble() * 1.0,
      waterTemperature: 24.0 + _random.nextDouble() * 4.0,
      waterVolume: 70.0 + _random.nextDouble() * 20.0,
      npk: NpkData(
        nitrogen: 10 + _random.nextDouble() * 5,
        phosphorus: 5 + _random.nextDouble() * 5,
        potassium: 15 + _random.nextDouble() * 10,
      ),
      timestamp: DateTime.now(),
    );
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _generateDummyData();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _mqttService.client.disconnect();
    super.dispose();
  }
}
