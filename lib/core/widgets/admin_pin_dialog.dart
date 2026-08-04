import 'package:flutter/material.dart';
import '../services/admin_pin_service.dart';

/// Helper untuk menampilkan dialog PIN Admin.
/// Fetch PIN dari Firebase, lalu tampilkan dialog input.
/// [onSuccess] dipanggil jika PIN benar.
Future<void> showAdminPinDialog(
  BuildContext context, {
  required VoidCallback onSuccess,
}) async {
  // 1. Tampilkan loading sementara fetch
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final String? cloudPin = await AdminPinService().fetchPin();

  // 2. Tutup loading
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  if (!context.mounted) return;

  // 3. Jika fetch gagal → tampilkan dialog PIN dengan peringatan offline
  final bool isOffline = cloudPin == null;

  final pinController = TextEditingController();
  bool isError = false;

  showDialog(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB923C).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded,
                            color: Color(0xFFFB923C)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Keamanan Admin',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Peringatan jika PIN tidak bisa di-fetch
                  if (isOffline)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB923C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              color: Color(0xFFFB923C), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mode offline — PIN tidak dapat diverifikasi ke server.',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFFFB923C)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Masukkan PIN admin untuk melanjutkan.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '• • • • • •',
                      errorText: isError ? 'PIN salah!' : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('BATAL',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOffline
                                ? Colors.grey
                                : const Color(0xFF38BDF8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: isOffline
                              ? null // Nonaktifkan tombol jika offline
                              : () {
                                  if (pinController.text == cloudPin) {
                                    Navigator.pop(context);
                                    onSuccess();
                                  } else {
                                    setState(() => isError = true);
                                  }
                                },
                          child: Text(
                            isOffline ? 'TIDAK TERSEDIA' : 'MASUK',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
