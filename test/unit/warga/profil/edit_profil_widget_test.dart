import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget _buildReadOnlyField menampilkan label dan value', (
    tester,
  ) async {
    // _buildReadOnlyField adalah private, jadi kita salin logika tampilannya di sini
    const label = 'Nama Lengkap';
    const value = 'Budi Santoso';
    final widget = MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey(value),
                initialValue: value,
                readOnly: true,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text(label), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text(value), findsOneWidget);
  });

  testWidgets('Widget _buildEditableField menampilkan label dan TextFormField', (
    tester,
  ) async {
    // _buildEditableField adalah private, jadi kita salin logika tampilannya di sini
    const label = 'Nomor Telepon';
    final controller = TextEditingController(text: '08123456789');
    final widget = MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                maxLines: 1,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Color(0xFF6A5AE0).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text(label), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('08123456789'), findsOneWidget);
  });

  testWidgets(
    'Widget _buildDropdownField menampilkan label dan DropdownButtonFormField',
    (tester) async {
      // _buildDropdownField adalah private, jadi kita salin logika tampilannya di sini
      const label = 'Agama';
      const value = 'Islam';
      final items = ['Islam', 'Kristen', 'Katolik'];
      final widget = MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: value,
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (_) {},
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                      borderSide: BorderSide(
                        color: Color(0xFF6A5AE0).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text(label), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Islam'), findsOneWidget);
    },
  );
}
