# SN Hydro

Aplikasi mobile berbasis Flutter untuk memantau dan mengontrol sistem hidroponik cerdas menggunakan mikrokontroler ESP32. Proyek ini merupakan hasil luaran (output) program Kuliah Kerja Nyata (KKN) Universitas Islam Madura Posko 1 di Desa Sumber Nangka.

## Deskripsi Sistem

SN Hydro mempermudah petani hidroponik dalam memantau kualitas air secara *real-time* tanpa harus mengecek langsung ke kebun. Aplikasi ini terhubung dengan perangkat keras (Node ESP32) melalui Firebase Realtime Database dan MQTT untuk menjamin kecepatan pertukaran data.

## Fitur Utama

1. **Dashboard Monitoring Real-Time**
   Membaca metrik utama seperti Suhu Air, tingkat keasaman (pH), dan konsentrasi nutrisi (TDS/PPM).
2. **Grafik Histori (Tren Data)**
   Menyajikan riwayat perubahan pH dan nutrisi dalam bentuk grafik garis.
3. **Kalibrasi Sensor Jarak Jauh (OTA)**
   Pengguna dapat menyesuaikan *K-Value* (untuk TDS) dan *Offset* (untuk pH) langsung dari aplikasi. Nilai akan langsung diterapkan ke mikrokontroler.
4. **Konfigurasi Jaringan Dinamis**
   Memungkinkan pengguna mengganti koneksi WiFi (SSID & Password) pada ESP32 secara jarak jauh, dilindungi dengan PIN Admin.
5. **Navigasi Adaptif (Floating Dock)**
   Antarmuka navigasi (menu) dapat digeser ke empat sisi layar (kiri, kanan, atas, bawah) sesuai preferensi pengguna.
6. **Pembaruan Aplikasi Mandiri**
   Aplikasi dapat memeriksa rilis versi terbaru di repositori GitHub dan langsung mengunduh/menginstal file APK-nya (*In-App Update*).

## Teknologi yang Digunakan

* **Frontend:** Flutter (Dart)
* **Hardware:** ESP32, Sensor pH, Sensor TDS, Sensor Suhu (DS18B20)
* **Backend & Komunikasi:** Firebase Realtime Database, MQTT
* **Desain UI:** Neumorphism (Mendukung mode Gelap dan Terang)

## Persyaratan Sistem

Untuk menjalankan atau memodifikasi aplikasi ini di lokal, Anda membutuhkan:
* Flutter SDK versi 3.12.0 atau lebih baru.
* Android Studio atau VS Code dengan ekstensi Flutter.
* Perangkat Android (Fisik atau Emulator) dengan API Level minimal 21.

## Cara Menjalankan

1. Kloning repositori ini.
2. Buka terminal di direktori proyek, lalu jalankan perintah instalasi dependensi:
   ```bash
   flutter pub get
   ```
3. Sambungkan perangkat Android atau nyalakan emulator.
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Lisensi dan Hak Cipta

© 2026 Tim KKN Desa Sumber Nangka.
Dirancang khusus untuk mendukung digitalisasi pertanian di tingkat SMP & SMK Sumber Nangka.
