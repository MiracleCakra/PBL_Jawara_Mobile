import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:SapaWarga_kel_2/main.dart' as app;
import '../../login_helper.dart';

// Personal Note:
// THE ONLY WORKING SHIT SO FAR.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  app.main();

  group('Admin Kegiatan Full E2E Test (Single Flow)', () {
    testWidgets(
      'Admin can create, view, edit, and delete a kegiatan in one continuous flow',
      (WidgetTester tester) async {
        // --- PART 1: CREATE KEGIATAN ---

        await login(tester, email: 'admin@gmail.com', password: 'password');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('kegiatan_tab')));
        await tester.tap(find.byKey(const Key('kegiatan_tab')));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.ensureVisible(
          find.byKey(const Key('daftar_kegiatan_button')),
        );
        await tester.tap(find.byKey(const Key('daftar_kegiatan_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.ensureVisible(find.byKey(const Key('add_kegiatan_fab')));
        await tester.tap(find.byKey(const Key('add_kegiatan_fab')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Fill form
        final namaKegiatan =
            'Kerja Bakti Tes E2E ${DateTime.now().millisecondsSinceEpoch}';
        final deskripsiKegiatan = 'Membersihkan lingkungan sekitar RT.';

        await tester.ensureVisible(
          find.byKey(const Key('nama_kegiatan_field')),
        );
        await tester.enterText(
          find.byKey(const Key('nama_kegiatan_field')),
          namaKegiatan,
        );

        // Select Kategori
        await tester.ensureVisible(
          find.byKey(const Key('kategori_kegiatan_dropdown')),
        );
        await tester.tap(find.byKey(const Key('kategori_kegiatan_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Kebersihan dan Keamanan').last);
        await tester.pumpAndSettle();

        // Select Tanggal
        await tester.ensureVisible(
          find.byKey(const Key('tanggal_kegiatan_field')),
        );
        await tester.tap(find.byKey(const Key('tanggal_kegiatan_field')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pilih'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.byKey(const Key('lokasi_kegiatan_field')),
        );
        await tester.enterText(
          find.byKey(const Key('lokasi_kegiatan_field')),
          'Sekitar RT 01',
        );

        await tester.ensureVisible(find.byKey(const Key('pj_kegiatan_field')));
        await tester.enterText(
          find.byKey(const Key('pj_kegiatan_field')),
          'Admin Test',
        );

        await tester.ensureVisible(
          find.byKey(const Key('deskripsi_kegiatan_field')),
        );
        await tester.enterText(
          find.byKey(const Key('deskripsi_kegiatan_field')),
          deskripsiKegiatan,
        );

        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byKey(const Key('upload_dokumentasi')));
        await tester.tap(find.byKey(const Key('upload_dokumentasi')));
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Save
        await tester.ensureVisible(
          find.byKey(const Key('simpan_kegiatan_button')),
        );
        await tester.tap(find.byKey(const Key('simpan_kegiatan_button')));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Handle success dialog
        await tester.ensureVisible(find.byKey(const Key('selesai_button')));
        await tester.tap(find.byKey(const Key('selesai_button')));
        await tester.pump(const Duration(seconds: 5));

        // Verify
        await tester.pump(const Duration(seconds: 10));
        await tester.ensureVisible(find.text(namaKegiatan));
        expect(find.text(namaKegiatan), findsOneWidget);
        print('STEP 1 COMPLETE: Kegiatan created successfully.');

        // --- PART 2: VIEW KEGIATAN DETAIL ---

        await tester.ensureVisible(find.text(namaKegiatan));
        await tester.tap(
          find.ancestor(
            of: find.text(namaKegiatan),
            matching: find.byType(GestureDetector),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Detail Kegiatan'), findsOneWidget);
        final detailNama = tester.widget<TextFormField>(
          find.byKey(const Key('detail_nama_kegiatan')),
        );
        expect(detailNama.initialValue, namaKegiatan);
        print('STEP 2 COMPLETE: Kegiatan detail viewed successfully.');

        // --- PART 3: EDIT KEGIATAN ---

        await tester.ensureVisible(
          find.byKey(const Key('kegiatan_more_actions_button')),
        );
        await tester.tap(find.byKey(const Key('kegiatan_more_actions_button')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const Key('edit_kegiatan_button')),
        );
        await tester.tap(find.byKey(const Key('edit_kegiatan_button')));
        await tester.pumpAndSettle();

        final editedNamaKegiatan = '$namaKegiatan (edited)';
        await tester.ensureVisible(
          find.byKey(const Key('edit_nama_kegiatan_field')),
        );
        await tester.enterText(
          find.byKey(const Key('edit_nama_kegiatan_field')),
          editedNamaKegiatan,
        );

        await tester.ensureVisible(
          find.byKey(const Key('simpan_edit_kegiatan_button')),
        );
        await tester.tap(find.byKey(const Key('simpan_edit_kegiatan_button')));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // After edit, it pops back to the list screen with a refresh flag
        await tester.ensureVisible(find.byKey(const Key('back_button')));
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Kegiatan'),
          ),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text(editedNamaKegiatan));
        expect(find.text(editedNamaKegiatan), findsOneWidget);
        expect(find.text(namaKegiatan), findsNothing);
        print('STEP 3 COMPLETE: Kegiatan edited successfully.');

        // --- PART 4: DELETE KEGIATAN ---

        await tester.ensureVisible(find.text(editedNamaKegiatan));
        await tester.tap(
          find.ancestor(
            of: find.text(editedNamaKegiatan),
            matching: find.byType(GestureDetector),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await tester.ensureVisible(
          find.byKey(const Key('kegiatan_more_actions_button')),
        );
        await tester.tap(find.byKey(const Key('kegiatan_more_actions_button')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const Key('delete_kegiatan_button')),
        );
        await tester.tap(find.byKey(const Key('delete_kegiatan_button')));
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.byKey(const Key('confirm_delete_kegiatan_button')),
        );
        await tester.tap(
          find.byKey(const Key('confirm_delete_kegiatan_button')),
        );
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Kegiatan'),
          ),
          findsOneWidget,
        );
        expect(find.text(editedNamaKegiatan), findsNothing);
        print('STEP 4 COMPLETE: Kegiatan deleted successfully.');
      },
    );
  });
}
