import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sensor_data.dart';

class SensorProvider extends ChangeNotifier {
  SensorData? _currentData;
  bool _isLoading = true;
  Timer? _pollingTimer;
  final HttpClient _httpClient = HttpClient();

  // URL Firebase Realtime Database
  final String _firebaseUrl = "https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app/devices/ESP32_01/current.json";

  SensorData? get currentData => _currentData;
  bool get isLoading => _isLoading;

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
      final request = await _httpClient.getUrl(Uri.parse(_firebaseUrl));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        if (responseBody != "null" && responseBody.isNotEmpty) {
          final data = jsonDecode(responseBody);
          
          _currentData = SensorData(
            ph: (data['ph'] ?? 0.0).toDouble(),
            tds: (data['tds'] ?? 0.0).toDouble(),
            ec: (data['ec'] ?? 0.0).toDouble(),
            waterTemperature: (data['temperature'] ?? 0.0).toDouble(), // Sesuai JSON Firebase
            waterVolume: 0.0, // Dihapus dari alat
            npk: NpkData(nitrogen: 0, phosphorus: 0, potassium: 0),
            timestamp: data['timestamp'] != null 
                ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
                : DateTime.now(),
          );
          
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
