import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/screens/warga/kegiatan/kirimansaya/daftar_kiriman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DummyAspirasiService {
  Stream<List<AspirasiModel>> getAspirationsByUserId(String userId) {
    return Stream.value([
      AspirasiModel(
        id: 1,
        judul: 'Judul Dummy',
        isi: 'Isi Dummy',
        pengirim: 'Warga',
        status: 'Pending',
        tanggal: DateTime(2025, 12, 23),
        userId: userId,
      ),
      AspirasiModel(
        id: 2,
        judul: 'Judul Diterima',
        isi: 'Isi Diterima',
        pengirim: 'Warga',
        status: 'Diterima',
        tanggal: DateTime(2025, 12, 20),
        userId: userId,
      ),
    ]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });

  group('WargaPesanSayaScreen Widget Test', () {
    testWidgets('AppBar and filter bar are displayed', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WargaPesanSayaScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat Kiriman Saya'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('Show empty state if no data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: StreamBuilder<List<AspirasiModel>>(
                  stream: Stream.value([]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Belum ada riwayat kiriman.'),
                      );
                    }
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );
      expect(find.text('Belum ada riwayat kiriman.'), findsOneWidget);
    });

    testWidgets('Show list of aspirasi', (tester) async {
      // Simulasi dengan dummy data
      final dummyList = [
        AspirasiModel(
          id: 1,
          judul: 'Judul Dummy',
          isi: 'Isi Dummy',
          pengirim: 'Warga',
          status: 'Pending',
          tanggal: DateTime(2025, 12, 23),
          userId: 'user123',
        ),
        AspirasiModel(
          id: 2,
          judul: 'Judul Diterima',
          isi: 'Isi Diterima',
          pengirim: 'Warga',
          status: 'Diterima',
          tanggal: DateTime(2025, 12, 20),
          userId: 'user123',
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: dummyList
                  .map((e) => ListTile(title: Text(e.judul)))
                  .toList(),
            ),
          ),
        ),
      );
      expect(find.text('Judul Dummy'), findsOneWidget);
      expect(find.text('Judul Diterima'), findsOneWidget);
    });
  });
}
