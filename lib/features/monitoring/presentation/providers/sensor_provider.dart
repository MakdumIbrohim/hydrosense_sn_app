import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sensor_data.dart';

class SensorProvider extends ChangeNotifier {
  SensorData? _currentData;
  bool _isLoading = true;
  final List<double> _ecHistory = [];
  Timer? _pollingTimer;
  final HttpClient _httpClient = HttpClient();

  // URL Firebase Realtime Database
  final String _firebaseUrl = "https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/current.json";

  SensorData? get currentData => _currentData;
  bool get isLoading => _isLoading;
  List<double> get ecHistory => _ecHistory;

  SensorProvider() {
    _initFirebasePolling();
  }

  void _initFirebasePolling() {
    // Tarik data pertama kali langsung
    _fetchDataFromFirebase();
    
    // Tarik data baru otomatis setiap 3 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchDataFromFirebase();
    });
  }

  Future<void> _fetchDataFromFirebase() async {
    try {
      // Tambahkan parameter acak (cache-buster) agar HTTP tidak menggunakan data lama
      final url = Uri.parse("$_firebaseUrl?_=${DateTime.now().millisecondsSinceEpoch}");
      final request = await _httpClient.getUrl(url);
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        if (responseBody != "null" && responseBody.isNotEmpty) {
          final data = jsonDecode(responseBody);
          
          _currentData = SensorData(
            ph: (data['ph'] ?? 0.0).toDouble(),
            tds: (data['tds'] ?? 0.0).toDouble(),
            ec: (data['ec'] ?? 0.0).toDouble(),
            waterTemperature: (data['temperature'] ?? 0.0).toDouble(),
            waterVolume: 0.0,
            npk: NpkData(nitrogen: 0, phosphorus: 0, potassium: 0),
            timestamp: data['timestamp'] != null 
                ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
                : DateTime.now(),
          );
          
          // Tambahkan histori untuk grafik (maks 20 data agar tidak kepenuhan RAM)
          if (_ecHistory.length >= 20) {
            _ecHistory.removeAt(0); // Buang yang paling lama
          }
          _ecHistory.add(_currentData!.ec);
          
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error narik data Firebase: $e');
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    await _fetchDataFromFirebase();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _httpClient.close();
    super.dispose();
  }
}
