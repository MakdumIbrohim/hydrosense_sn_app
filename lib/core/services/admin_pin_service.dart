import 'dart:convert';
import 'dart:io';

/// Service untuk mengambil PIN admin dari Firebase Realtime Database.
/// PIN disimpan di node: /devices/ESP32_01/config/admin_pin
/// Tidak memerlukan SDK Firebase — cukup HTTP REST.
class AdminPinService {
  static const _baseUrl =
      'https://hydrosensesn-default-rtdb.asia-southeast1.firebasedatabase.app';
  static const _pinPath = '/devices/ESP32_01/config/admin_pin.json';

  /// Mengambil PIN admin dari Firebase.
  /// Mengembalikan [String] PIN bila berhasil, atau [null] bila gagal.
  Future<String?> fetchPin() async {
    try {
      final url = Uri.parse('$_baseUrl$_pinPath');
      final request = await HttpClient().getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(body);
        if (decoded != null && decoded is String) {
          return decoded;
        }
        // Handle jika PIN disimpan sebagai integer di Firebase
        if (decoded != null) {
          return decoded.toString();
        }
      }
    } catch (_) {
      // Jika terjadi error (mis. tidak ada internet / rules blocked)
    }
    return null;
  }
}
