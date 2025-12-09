import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara_pintar_kel_5/main.dart' as app;

import '../login_helper.dart';

// Helper function to perform logout
Future<void> logout(WidgetTester tester) async {
  // Navigate to the 'Lainnya' screen
  await tester.tap(find.byKey(const Key('lainnya_tab')));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  
  // Tap the initial logout button
  await tester.tap(find.byKey(const Key('logout_button')));
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // Tap the confirmation logout button in the dialog
  await tester.tap(find.byKey(const Key('confirm_logout_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify logout was successful by finding the initial login button again
  expect(find.byKey(const Key('btn_show_login_form')), findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Broadcast E2E Test (Independent Tests)', () {
    
    testWidgets('successfully navigates to the "Daftar Broadcast" screen and logs out', (WidgetTester tester) async {
      await login(tester, email: 'admin@gmail.com', password: 'password');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('daftar_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Broadcast'), findsOneWidget);
      
      await logout(tester);
    });

    testWidgets('creates a new broadcast successfully and logs out', (WidgetTester tester) async {
      await login(tester, email: 'admin@gmail.com', password: 'password');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('daftar_broadcast_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add_broadcast_fab')));
      await tester.pumpAndSettle();

      final broadcastTitle = 'Pengumuman Create ${DateTime.now().millisecondsSinceEpoch}';
      await tester.ensureVisible(find.byKey(const Key('judul_broadcast_field')));
      await tester.enterText(find.byKey(const Key('judul_broadcast_field')), broadcastTitle);
      await tester.ensureVisible(find.byKey(const Key('simpan_broadcast_button')));
      await tester.tap(find.byKey(const Key('simpan_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text(broadcastTitle), findsOneWidget);

      await logout(tester);
    });

    testWidgets('edits a broadcast successfully and logs out', (WidgetTester tester) async {
      await login(tester, email: 'admin@gmail.com', password: 'password');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('daftar_broadcast_button')));
      await tester.pumpAndSettle();
      
      // Create an item to edit first
      final originalTitle = 'Broadcast Utk Diedit ${DateTime.now().millisecondsSinceEpoch}';
      await tester.tap(find.byKey(const Key('add_broadcast_fab')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('judul_broadcast_field')), originalTitle);
      await tester.tap(find.byKey(const Key('simpan_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Navigate to detail and edit
      await tester.tap(find.text(originalTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more_actions_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit_broadcast_button')));
      await tester.pumpAndSettle();

      // Edit the title and save
      final editedTitle = '$originalTitle (edited)';
      await tester.enterText(find.byKey(const Key('edit_judul_broadcast_field')), editedTitle);
      await tester.tap(find.byKey(const Key('simpan_edit_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify edit on detail screen
      final updatedTitle = tester.widget<Text>(find.byKey(const Key('broadcast_detail_title')));
      expect(updatedTitle.data, editedTitle);

      // Go back and verify on list screen
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(editedTitle), findsOneWidget);
      expect(find.text(originalTitle), findsNothing);

      await logout(tester);
    });

    testWidgets('deletes a broadcast successfully and logs out', (WidgetTester tester) async {
      await login(tester, email: 'admin@gmail.com', password: 'password');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('daftar_broadcast_button')));
      await tester.pumpAndSettle();

      // Create an item to delete
      final broadcastTitleToDelete = 'Broadcast Utk Dihapus ${DateTime.now().millisecondsSinceEpoch}';
      await tester.tap(find.byKey(const Key('add_broadcast_fab')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('judul_broadcast_field')), broadcastTitleToDelete);
      await tester.tap(find.byKey(const Key('simpan_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text(broadcastTitleToDelete), findsOneWidget);

      // Navigate to detail and delete
      await tester.tap(find.text(broadcastTitleToDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more_actions_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_broadcast_button')));
      await tester.pumpAndSettle();

      // Confirm deletion in dialog
      final hapusDialogButton = find.widgetWithText(ElevatedButton, 'Hapus');
      expect(hapusDialogButton, findsOneWidget);
      await tester.tap(hapusDialogButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // FIX: Verify the item is gone from the list screen.
      // Do not drag if the list might be empty. Just check that the item is not found.
      expect(find.text('Broadcast'), findsOneWidget); // We should be back on the list screen
      expect(find.text(broadcastTitleToDelete), findsNothing);

      await logout(tester);
    });
  });
}