import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget _buildEmptyOrders menampilkan pesan kosong', (
    tester,
  ) async {
    final widget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 10),
                Text(
                  'Belum ada pesanan masuk.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Belum ada pesanan masuk.'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('Widget _buildEmptyFilteredOrders menampilkan pesan filter', (
    tester,
  ) async {
    const selectedFilter = 'Selesai';
    final widget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_alt_off,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tidak ada pesanan $selectedFilter',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Tidak ada pesanan Selesai'), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_off), findsOneWidget);
  });
}
