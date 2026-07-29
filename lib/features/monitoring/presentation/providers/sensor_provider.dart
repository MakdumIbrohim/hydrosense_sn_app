import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../../domain/entities/sensor_data.dart';

class SensorProvider extends ChangeNotifier {
  SensorData? _currentData;
  bool _isLoading = true;
  final List<double> _ecHistory = [];
  
  MqttServerClient? _mqttClient;
  final String _broker = 'broker.emqx.io';
  final int _port = 1883;
  final String _topic = 'hydrosense/sn/ESP32_01/current';

  SensorData? get currentData => _currentData;
  bool get isLoading => _isLoading;
  List<double> get ecHistory => _ecHistory;

  SensorProvider() {
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    // Setup MQTT Client dengan ID unik
    _mqttClient = MqttServerClient(_broker, 'hydrosense_flutter_${Random().nextInt(100000)}');
    _mqttClient!.port = _port;
    _mqttClient!.keepAlivePeriod = 20;
    _mqttClient!.onDisconnected = _onDisconnected;
    _mqttClient!.onConnected = _onConnected;
    
    try {
      debugPrint('Menyambungkan ke Broker EMQX...');
      await _mqttClient!.connect();
    } catch (e) {
      debugPrint('Gagal connect: $e');
      _mqttClient!.disconnect();
    }

    if (_mqttClient!.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('Berhasil tersambung ke EMQX!');
      _mqttClient!.subscribe(_topic, MqttQos.atMostOnce);

      _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        try {
          final data = jsonDecode(pt);
          
          _currentData = SensorData(
            ph: (data['ph'] ?? 0.0).toDouble(),
            tds: (data['tds'] ?? 0.0).toDouble(),
            ec: (data['ec'] ?? 0.0).toDouble(),
            waterTemperature: (data['temperature'] ?? 0.0).toDouble(),
            waterVolume: 0.0,
            npk: NpkData(nitrogen: 0, phosphorus: 0, potassium: 0),
            wifiSsid: data['wifi_ssid'] ?? 'WiFi Terhubung',
            timestamp: DateTime.now(), // Realtime saat pesan MQTT diterima
          );
          
          if (_ecHistory.length >= 20) {
            _ecHistory.removeAt(0);
          }
          _ecHistory.add(_currentData!.ec);
          
          _isLoading = false;
          notifyListeners();
        } catch (e) {
          debugPrint('Error memproses data MQTT: $e');
        }
      });
    }
  }

  void _onConnected() {
    debugPrint('Terkoneksi ke EMQX');
  }

  void _onDisconnected() {
    debugPrint('Terputus dari EMQX. Mencoba menyambung kembali...');
    Future.delayed(const Duration(seconds: 5), _initMqtt);
  }

  Future<void> refreshData() async {
    // Karena MQTT Realtime (terlempar langsung oleh server), refresh hanya untuk cek koneksi
    _isLoading = true;
    notifyListeners();
    if (_mqttClient?.connectionStatus?.state != MqttConnectionState.connected) {
      await _initMqtt();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mqttClient?.disconnect();
    super.dispose();
  }
}
