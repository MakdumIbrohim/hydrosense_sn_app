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
  String _connectionMessage = 'Menginisialisasi sistem...';
  final List<double> _ecHistory = [];
  final List<double> _phHistory = [];
  final List<double> _tdsHistory = [];
  final List<double> _tempHistory = [];
  
  MqttServerClient? _mqttClient;
  final String _broker = 'broker.emqx.io';
  final int _port = 1883;
  final String _topic = 'hydrosense/sn/ESP32_01/current';

  SensorData? get currentData => _currentData;
  bool get isLoading => _isLoading;
  String get connectionMessage => _connectionMessage;
  List<double> get ecHistory => _ecHistory;
  List<double> get phHistory => _phHistory;
  List<double> get tdsHistory => _tdsHistory;
  List<double> get tempHistory => _tempHistory;

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
      _connectionMessage = 'Menyambungkan ke Broker EMQX...';
      notifyListeners();
      debugPrint(_connectionMessage);
      await _mqttClient!.connect();
    } catch (e) {
      _connectionMessage = 'Gagal terhubung: $e';
      notifyListeners();
      debugPrint(_connectionMessage);
      _mqttClient!.disconnect();
    }

    if (_mqttClient!.connectionStatus!.state == MqttConnectionState.connected) {
      _connectionMessage = 'Tersambung ke server. Menunggu data...';
      notifyListeners();
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
            _phHistory.removeAt(0);
            _tdsHistory.removeAt(0);
            _tempHistory.removeAt(0);
          }
          _ecHistory.add(_currentData!.ec);
          _phHistory.add(_currentData!.ph);
          _tdsHistory.add(_currentData!.tds);
          _tempHistory.add(_currentData!.waterTemperature);
          
          _isLoading = false;
          _connectionMessage = 'Data diterima.';
          notifyListeners();
        } catch (e) {
          debugPrint('Error memproses data MQTT: $e');
        }
      });
    }
  }

  void _onConnected() {
    _connectionMessage = 'Terkoneksi ke server.';
    notifyListeners();
    debugPrint('Terkoneksi ke EMQX');
  }

  void _onDisconnected() {
    _connectionMessage = 'Koneksi terputus. Mencoba menyambung kembali...';
    _isLoading = true;
    notifyListeners();
    debugPrint('Terputus dari EMQX. Mencoba menyambung kembali...');
    Future.delayed(const Duration(seconds: 5), _initMqtt);
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _connectionMessage = 'Memeriksa koneksi server...';
    notifyListeners();
    if (_mqttClient?.connectionStatus?.state != MqttConnectionState.connected) {
      await _initMqtt();
    } else {
      _connectionMessage = 'Koneksi stabil. Menunggu pembaruan data...';
      // Kita beri sedikit delay agar skeleton loading terlihat bahwa sistem bekerja
      await Future.delayed(const Duration(milliseconds: 800));
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
