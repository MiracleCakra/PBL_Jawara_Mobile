import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../login_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Broadcast Full E2E Test (Single Flow)', () {

    testWidgets('Admin can create, view, edit, and delete a broadcast in one continuous flow',
        (WidgetTester tester) async {
      
      // --- PART 1: CREATE BROADCAST ---
      
      await login(tester, email: 'admin@gmail.com', password: 'password');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('daftar_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('add_broadcast_fab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      String broadcastTitle = 'Pengumuman Tes E2E Single Flow ${DateTime.now().millisecondsSinceEpoch}';
      String broadcastContent = 'Ini adalah isi dari pengumuman penting yang dibuat melalui end-to-end test.';
      
      final titleField = find.byKey(const Key('judul_broadcast_field'));
      final contentField = find.byKey(const Key('isi_broadcast_field'));
      final simpanButton = find.byKey(const Key('simpan_broadcast_button'));

      await tester.ensureVisible(titleField);
      await tester.enterText(titleField, broadcastTitle);
      await tester.pumpAndSettle();

      await tester.ensureVisible(contentField);
      await tester.enterText(contentField, broadcastContent);
      await tester.pumpAndSettle();

      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.drag(find.byType(ListView), const Offset(0.0, 300.0));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text(broadcastTitle), findsOneWidget);
      print('STEP 1 COMPLETE: Broadcast created successfully.');

      // --- PART 2: VIEW BROADCAST DETAIL ---

      await tester.tap(find.text(broadcastTitle));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Detail Broadcast'), findsOneWidget);
      final detailTitle = tester.widget<Text>(find.byKey(const Key('broadcast_detail_title')));
      expect(detailTitle.data, broadcastTitle);
      print('STEP 2 COMPLETE: Broadcast detail viewed successfully.');

      // --- PART 3: EDIT BROADCAST ---

      await tester.tap(find.byKey(const Key('more_actions_button')));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.byKey(const Key('edit_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      String editedBroadcastTitle = '$broadcastTitle (edited)';
      final editTitleField = find.byKey(const Key('edit_judul_broadcast_field'));
      
      await tester.ensureVisible(editTitleField);
      await tester.enterText(editTitleField, editedBroadcastTitle);
      await tester.pumpAndSettle();

      final simpanEditButton = find.byKey(const Key('simpan_edit_broadcast_button'));
      await tester.ensureVisible(simpanEditButton);
      await tester.tap(simpanEditButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final updatedDetailTitle = tester.widget<Text>(find.byKey(const Key('broadcast_detail_title')));
      expect(updatedDetailTitle.data, editedBroadcastTitle);
      print('STEP 3 COMPLETE: Broadcast edited successfully.');

      // --- PART 4: DELETE BROADCAST ---

      // From the detail screen, open the menu again
      await tester.tap(find.byKey(const Key('more_actions_button')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the delete button in the bottom sheet
      await tester.tap(find.byKey(const Key('delete_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // A confirmation dialog appears. Find the final "Hapus" button and tap it.
      final hapusDialogButton = find.widgetWithText(ElevatedButton, 'Hapus');
      expect(hapusDialogButton, findsOneWidget);
      await tester.tap(hapusDialogButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we are back on the list screen and the item is gone.
      expect(find.text('Broadcast'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0.0, 300.0));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text(editedBroadcastTitle), findsNothing);
      print('STEP 4 COMPLETE: Broadcast deleted and verified successfully.');
    });
  });
}
