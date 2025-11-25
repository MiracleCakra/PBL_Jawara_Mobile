import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/detail_penerimaan_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';

void main() {
  final mockData = PenerimaanWarga(
    nama: "Budi Santoso",
    nik: "123456789",
    jenisKelamin: "Laki-laki",
    email: "budi@example.com",
    status: "pending",
  );

  Widget createTestWidget() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) =>
              DetailPenerimaanWargaPage(penerimaan: mockData),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets("Menampilkan data dasar penerimaan", (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.text("Budi Santoso"), findsOneWidget);
    expect(find.text("123456789"), findsOneWidget);
    expect(find.text("Laki-laki"), findsOneWidget);
    expect(find.text("pending"), findsOneWidget);
  });

  testWidgets("Menampilkan tombol Tolak & Setujui ketika status pending",
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.text("Tolak"), findsOneWidget);
    expect(find.text("Setujui"), findsOneWidget);
  });

  testWidgets("Menampilkan bottom sheet saat tombol Tolak ditekan",
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    await tester.tap(find.text("Tolak"));
    await tester.pumpAndSettle();

    // cek bottom sheet muncul
    expect(find.text("Alasan Penolakan"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets("Validasi kosong pada alasan penolakan", (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    await tester.tap(find.text("Tolak"));
    await tester.pumpAndSettle();

    // Tekan tombol submit tanpa isi
    await tester.tap(find.text("Kirim Penolakan"));
    await tester.pumpAndSettle();

    expect(find.text("Alasan penolakan harus diisi"), findsOneWidget);
  });
}
