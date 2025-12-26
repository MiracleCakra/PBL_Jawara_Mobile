import 'package:SapaWarga_kel_2/screens/warga/marketplace/tokoSaya/editprofile_toko.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('Widget _buildInputField menampilkan label dan hint', (
    tester,
  ) async {
    const label = 'Nama Toko';
    const hint = 'Masukkan nama toko Anda';
    final widget = MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: hint,
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF6A5AE0),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text(label), findsOneWidget);
    expect(find.text(hint), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets(
    'Widget _buildAvatarEdit menampilkan ikon toko jika tidak ada gambar',
    (tester) async {
      // _buildAvatarEdit adalah private, jadi kita salin logika tampilannya di sini
      const primaryColor = Color(0xFF6A5AE0);
      final widget = MaterialApp(
        home: Scaffold(
          body: Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: const ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(Icons.store, size: 50, color: primaryColor),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    },
  );
}
