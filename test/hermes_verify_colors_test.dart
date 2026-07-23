import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hydrosense_sn_app/core/constants/app_colors.dart';
import 'package:hydrosense_sn_app/core/widgets/custom_top_bar.dart';

void main() {
  testWidgets('AppColors are accessible', (WidgetTester tester) async {
    expect(AppColors.primary, const Color(0xFF009688));
    expect(AppColors.error, const Color(0xFFF44336));
  });

  testWidgets('CustomTopBar uses modern opacity', (WidgetTester tester) async {
    int tapCount = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomTopBar(
          selectedIndex: 0,
          onItemTapped: (idx) {
            tapCount++;
          },
        ),
      ),
    ));
    
    // Tap second item
    await tester.tap(find.byIcon(Icons.propane_tank_outlined));
    expect(tapCount, 1);
  });
}
