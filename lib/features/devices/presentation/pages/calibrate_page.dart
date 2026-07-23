import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CalibratePage extends StatelessWidget {
  final String id;
  const CalibratePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kalibrasi: $id')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text('Pembacaan Live (Mentah)', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('pH 4.32', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Langkah Kalibrasi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('1. Bersihkan sensor dengan air distilasi (aquades).\n2. Celupkan ke cairan buffer standar (misal pH 4.01 atau 6.86).\n3. Tunggu angka live stabil.\n4. Simpan nilai kalibrasi di bawah ini.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Simpan sebagai pH 4.01'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Simpan sebagai pH 6.86'),
            ),
          ],
        ),
      ),
    );
  }
}