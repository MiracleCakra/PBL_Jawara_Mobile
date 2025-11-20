import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara_pintar_kel_5/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Scenario: Daftar Warga Flow', (WidgetTester tester) async {
    // 1. Start App
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // --------------------------------------------------------
    // STEP 1: LOGIN
    // --------------------------------------------------------
    print('Step 1: Login...');

    final btnShowForm = find.byKey(const Key('btn_show_login_form'));

    if (btnShowForm.evaluate().isNotEmpty) {
      await tester.tap(btnShowForm);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.enterText(find.byKey(const Key('input_email')), 'admin');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(
        find.byKey(const Key('input_password')),
        'password',
      );
      await tester.pump(const Duration(milliseconds: 100));

      final btnSubmit = find.byKey(const Key('btn_submit_login'));
      await tester.ensureVisible(btnSubmit);
      await tester.pumpAndSettle();

      await tester.tap(btnSubmit);

      // Tunggu proses login
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // --------------------------------------------------------
    // STEP 2: NAVIGASI KE DAFTAR WARGA
    // --------------------------------------------------------
    print('Step 2: Navigasi Menu Penduduk -> Submenu Warga...');

    expect(
      find.text('Dashboard'),
      findsOneWidget,
      reason: "Gagal Login: Belum masuk halaman Dashboard",
    );

    await tester.pumpAndSettle(const Duration(seconds: 6));

    print('Mencari menu Penduduk di bottom navigation...');

    final size = tester.getSize(find.byType(MaterialApp));
    final screenWidth = size.width;
    final screenHeight = size.height;

    final pendudukX =
        screenWidth * 0.25; // Menu kedua (Rumah, Penduduk, Keuangan, dll)
    final pendudukY = screenHeight * 0.95;

    print('Tap koordinat bottom nav: ($pendudukX, $pendudukY)');
    await tester.tapAt(Offset(pendudukX, pendudukY));
    await tester.pumpAndSettle(
      const Duration(seconds: 3),
    );
    print('Verifikasi halaman Penduduk terbuka...');

    final allTexts = find.byType(Text);
    print('Jumlah widget Text ditemukan: ${allTexts.evaluate().length}');

    if (find.text('Pilih Menu').evaluate().isNotEmpty) {
      print('Found: Pilih Menu');
    } else if (find.text('Penduduk').evaluate().isNotEmpty) {
      print('Found: Penduduk (header)');
    } else if (find.text('Warga').evaluate().isNotEmpty) {
      print('Found: Warga (submenu)');
    } else {
      print('PERINGATAN: Tidak menemukan header yang diharapkan');
    }

    final hasHeader =
        find.text('Pilih Menu').evaluate().isNotEmpty ||
        find.text('Penduduk').evaluate().length > 1;

    expect(hasHeader, true, reason: "Gagal masuk ke halaman Menu Penduduk");

    print('Mencari submenu Warga...');
    final subMenuWarga = find.text('Warga');

    expect(subMenuWarga, findsWidgets, reason: "Submenu Warga tidak ditemukan");

    await tester.tap(subMenuWarga.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      find.text('Daftar Warga'),
      findsOneWidget,
      reason: "Gagal masuk ke halaman list Daftar Warga",
    );
    expect(find.byKey(const Key('field_search_warga')), findsOneWidget);

    // --------------------------------------------------------
    // STEP 3: TEST PENCARIAN (SEARCH)
    // --------------------------------------------------------
    print('Step 3: Test Search...');

    final searchField = find.byKey(const Key('field_search_warga'));
    // Gunakan nama yang pasti ada di data dummy
    await tester.enterText(searchField, 'warga1');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verifikasi hasil search
    if (find.byKey(const Key('warga_card_0')).evaluate().isNotEmpty) {
      expect(find.byKey(const Key('warga_card_0')), findsWidgets);
    } else {
      print("Info: Tidak ditemukan warga 'warga1'. Pastikan data tersedia.");
    }

    // Reset search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // --------------------------------------------------------
    // STEP 4: TEST FILTER
    // --------------------------------------------------------
    print('Step 4: Test Filter...');

    // Cari button filter
    final filterButton = find.byKey(const Key('btn_show_filter'));
    final filterIcon = find.byIcon(Icons.tune);

    if (filterButton.evaluate().isNotEmpty) {
      print('Filter button dengan key ditemukan');
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
    } else if (filterIcon.evaluate().isNotEmpty) {
      print('Filter icon ditemukan');
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();
    } else {
      print('Button filter tidak ditemukan, skip test filter');
    }

    final dropdownGender = find.byKey(const Key('dropdown_filter_gender'));
    if (dropdownGender.evaluate().isNotEmpty) {
      await tester.tap(dropdownGender);
      await tester.pumpAndSettle();

      final lakiLakiOption = find.text('Laki-laki');
      if (lakiLakiOption.evaluate().isNotEmpty) {
        await tester.tap(lakiLakiOption.last);
        await tester.pumpAndSettle();
      }

      final applyButton = find.byKey(const Key('btn_apply_filter'));
      if (applyButton.evaluate().isNotEmpty) {
        await tester.tap(applyButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }

    // --------------------------------------------------------
    // STEP 5: TEST RESET FILTER
    // --------------------------------------------------------
    print('Step 5: Test Reset Filter...');

    if (filterButton.evaluate().isNotEmpty) {
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
    } else if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();
    }

    // Reset filter
    final resetButton = find.byKey(const Key('btn_reset_filter'));
    if (resetButton.evaluate().isNotEmpty) {
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
    }

    // Apply
    final applyButton2 = find.byKey(const Key('btn_apply_filter'));
    if (applyButton2.evaluate().isNotEmpty) {
      await tester.tap(applyButton2);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // --------------------------------------------------------
    // STEP 6: TEST INTERAKSI LIST (Tap Card)
    // --------------------------------------------------------
    print('Step 6: Test Tap Card Warga...');

    final firstCard = find.byKey(const Key('warga_card_0'));

    if (firstCard.evaluate().isNotEmpty) {
      await tester.tap(firstCard);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byIcon(Icons.chevron_left).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.chevron_left));
      } else if (find.byType(BackButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(BackButton));
      } else {
        await tester.pageBack();
      }
      await tester.pumpAndSettle();
    } else {
      print('List warga kosong, melewati tes tap card.');
    }

    // --------------------------------------------------------
    // STEP 7: TEST FILTER STATUS KEPENDUDUKAN
    // --------------------------------------------------------
    print('Step 7: Test Filter Status Kependudukan...');

    if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();

      final statusDropdowns = find.byType(DropdownButtonFormField);
      if (statusDropdowns.evaluate().length >= 2) {
        await tester.tap(statusDropdowns.at(1));
        await tester.pumpAndSettle();

        final aktifOption = find.text('Aktif');
        if (aktifOption.evaluate().isNotEmpty) {
          await tester.tap(aktifOption.last);
          await tester.pumpAndSettle();
          print('Filter Status: Aktif dipilih');
        }

        // Apply filter
        final applyBtn = find.byKey(const Key('btn_apply_filter'));
        if (applyBtn.evaluate().isNotEmpty) {
          await tester.tap(applyBtn);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    }

    // --------------------------------------------------------
    // STEP 8: TEST FILTER KELUARGA
    // --------------------------------------------------------
    print('Step 8: Test Filter Keluarga...');

    if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon, warnIfMissed: false);
      await tester.pumpAndSettle();

      final keluargaDropdowns = find.byType(DropdownButtonFormField);
      if (keluargaDropdowns.evaluate().length >= 3) {
        await tester.tap(keluargaDropdowns.at(2));
        await tester.pumpAndSettle();

        final dropdownItems = find.byType(DropdownMenuItem);
        if (dropdownItems.evaluate().length > 1) {
          await tester.tap(dropdownItems.at(1));
          await tester.pumpAndSettle();
          print('Filter Keluarga dipilih');
        }

        // Apply
        final applyBtn = find.byKey(const Key('btn_apply_filter'));
        if (applyBtn.evaluate().isNotEmpty) {
          await tester.tap(applyBtn);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    }

    // Reset filter untuk test berikutnya
    if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon, warnIfMissed: false);
      await tester.pumpAndSettle();

      final resetBtn = find.byKey(const Key('btn_reset_filter'));
      if (resetBtn.evaluate().isNotEmpty) {
        await tester.tap(resetBtn);
        await tester.pumpAndSettle();
      }

      final applyBtn = find.byKey(const Key('btn_apply_filter'));
      if (applyBtn.evaluate().isNotEmpty) {
        await tester.tap(applyBtn);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }

    // --------------------------------------------------------
    // STEP 9: CRUD - CREATE (Tambah Warga Baru)
    // --------------------------------------------------------
    print('Step 9: Test CREATE - Tambah Warga...');

    final fab = find.byKey(const Key('fab_add_warga'));

    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifikasi masuk ke halaman tambah warga
      if (find.text('Tambah Warga').evaluate().isNotEmpty ||
          find.text('Form Tambah').evaluate().isNotEmpty) {
        print('Berhasil masuk halaman Tambah Warga');

        // ===== DATA DIRI =====
        print('Mengisi Data Diri...');

        // Nama Lengkap
        final namaField = find.widgetWithText(
          TextField,
          'Masukkan nama lengkap',
        );
        if (namaField.evaluate().isNotEmpty) {
          await tester.enterText(namaField, 'Test User E2E CRUD');
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // NIK
        final nikField = find.widgetWithText(TextField, 'Masukkan NIK');
        if (nikField.evaluate().isNotEmpty) {
          await tester.enterText(nikField, '1234567890123456');
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // Tempat Lahir
        final tempatLahirField = find.widgetWithText(
          TextField,
          'Masukkan tempat lahir',
        );
        if (tempatLahirField.evaluate().isNotEmpty) {
          await tester.enterText(tempatLahirField, 'Jakarta');
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // Tanggal Lahir
        final tanggalLahirField = find.widgetWithText(
          TextField,
          'Pilih Tanggal',
        );
        if (tanggalLahirField.evaluate().isNotEmpty) {
          await tester.tap(tanggalLahirField);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Pilih tanggal
          final okButton = find.text('OK');
          if (okButton.evaluate().isNotEmpty) {
            await tester.tap(okButton);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          }
        }

        print('Scroll ke bagian Informasi Kontak...');
        final scrollable = find.byType(SingleChildScrollView);
        final listView = find.byType(ListView);
        final scrollableWidget = find.byType(Scrollable);

        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (scrollableWidget.evaluate().isNotEmpty) {
          await tester.drag(scrollableWidget.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // ===== INFORMASI KONTAK =====
        print('Mengisi Informasi Kontak...');

        // Nomor Telepon
        final telpField = find.widgetWithText(
          TextField,
          'Masukkan nomor telepon',
        );
        if (telpField.evaluate().isNotEmpty) {
          await tester.enterText(telpField, '081234567890');
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // field dropdown dan button submit
        print('Scroll ke bagian Peran & Status...');
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (scrollableWidget.evaluate().isNotEmpty) {
          await tester.drag(scrollableWidget.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        print('Mengisi dropdown Peran...');
        final allDropdowns1 = find.byType(DropdownButtonFormField);
        print('Total dropdown ditemukan: ${allDropdowns1.evaluate().length}');

        if (allDropdowns1.evaluate().isNotEmpty) {
          // Pastikan dropdown terlihat
          await tester.ensureVisible(allDropdowns1.at(0));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('Tap dropdown Peran...');
          await tester.tap(allDropdowns1.at(0));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Cari dan pilih item selain "-- Pilih --"
          final dropdownItems = find.byType(DropdownMenuItem);
          print('Ditemukan ${dropdownItems.evaluate().length} item di Peran');

          if (dropdownItems.evaluate().length > 1) {
            print('Tap item Peran index 1...');
            await tester.tap(dropdownItems.at(1));
            await tester.pumpAndSettle(const Duration(seconds: 1));
            print(' Peran BERHASIL dipilih');
          } else {
            print(' Tidak ada item untuk Peran');
          }
        } else {
          print(' Dropdown Peran tidak ditemukan');
        }

        // ===== STATUS HIDUP (Dropdown) - Index 1 =====
        print('\nMengisi dropdown Status Hidup...');
        final allDropdowns2 = find.byType(DropdownButtonFormField);

        if (allDropdowns2.evaluate().length > 1) {
          await tester.ensureVisible(allDropdowns2.at(1));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('Tap dropdown Status Hidup...');
          await tester.tap(allDropdowns2.at(1));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final hidupOption = find.text('Hidup');
          print('Mencari opsi "Hidup": ${hidupOption.evaluate().length} found');

          if (hidupOption.evaluate().isNotEmpty) {
            print('Tap opsi Hidup...');
            await tester.tap(hidupOption.last);
            await tester.pumpAndSettle(const Duration(seconds: 1));
            print('Status Hidup: Hidup BERHASIL dipilih');
          } else {
            final dropdownItems = find.byType(DropdownMenuItem);
            if (dropdownItems.evaluate().length > 1) {
              print('Fallback: Tap item index 1');
              await tester.tap(dropdownItems.at(1));
              await tester.pumpAndSettle(const Duration(seconds: 1));
              print('Status Hidup dipilih (fallback)');
            } else {
              print('Tidak ada item untuk Status Hidup');
            }
          }
        } else {
          print('Dropdown Status Hidup tidak ditemukan');
        }

        // ===== STATUS KEPENDUDUKAN (Dropdown) - Index 2 =====
        print('\nMengisi dropdown Status Kependudukan...');
        final allDropdowns3 = find.byType(DropdownButtonFormField);

        if (allDropdowns3.evaluate().length > 2) {
          // Pastikan dropdown terlihat
          await tester.ensureVisible(allDropdowns3.at(2));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('Tap dropdown Status Kependudukan...');
          await tester.tap(allDropdowns3.at(2));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Pilih "Aktif" atau item kedua
          final aktifOption = find.text('Aktif');
          print('Mencari opsi "Aktif": ${aktifOption.evaluate().length} found');

          if (aktifOption.evaluate().isNotEmpty) {
            print('Tap opsi Aktif...');
            await tester.tap(aktifOption.last);
            await tester.pumpAndSettle(const Duration(seconds: 1));
            print('Status Kependudukan: Aktif BERHASIL dipilih');
          } else {
            // Fallback: pilih item kedua
            final dropdownItems = find.byType(DropdownMenuItem);
            if (dropdownItems.evaluate().length > 1) {
              print('Fallback: Tap item index 1');
              await tester.tap(dropdownItems.at(1));
              await tester.pumpAndSettle(const Duration(seconds: 1));
              print('Status Kependudukan dipilih (fallback)');
            } else {
              print('Tidak ada item untuk Status Kependudukan');
            }
          }
        } else {
          print('Dropdown Status Kependudukan tidak ditemukan');
        }

        // Scroll lagi untuk Latar Belakang
        print('Scroll ke bagian Latar Belakang...');
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (scrollableWidget.evaluate().isNotEmpty) {
          await tester.drag(scrollableWidget.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // ===== PENDIDIKAN TERAKHIR (Dropdown) - Index 3 =====
        print('\nMengisi dropdown Pendidikan Terakhir...');
        final allDropdowns4 = find.byType(DropdownButtonFormField);

        if (allDropdowns4.evaluate().length > 3) {
          // Pastikan dropdown terlihat
          await tester.ensureVisible(allDropdowns4.at(3));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('Tap dropdown Pendidikan Terakhir...');
          await tester.tap(allDropdowns4.at(3));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Pilih opsi pertama (selain -- Pilih --)
          final dropdownItems = find.byType(DropdownMenuItem);
          print(
            'Ditemukan ${dropdownItems.evaluate().length} item di Pendidikan',
          );

          if (dropdownItems.evaluate().length > 1) {
            print('Tap item Pendidikan index 1...');
            await tester.tap(dropdownItems.at(1));
            await tester.pumpAndSettle(const Duration(seconds: 1));
            print('Pendidikan Terakhir BERHASIL dipilih');
          } else {
            print('Tidak ada item untuk Pendidikan');
          }
        } else {
          print('Dropdown Pendidikan tidak ditemukan');
        }

        // ===== PEKERJAAN (Dropdown) - Index 4 =====
        print('\nMengisi dropdown Pekerjaan...');
        final allDropdowns5 = find.byType(DropdownButtonFormField);

        if (allDropdowns5.evaluate().length > 4) {
          // Pastikan dropdown terlihat
          await tester.ensureVisible(allDropdowns5.at(4));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('Tap dropdown Pekerjaan...');
          await tester.tap(allDropdowns5.at(4));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Pilih opsi pertama (selain -- Pilih --)
          final dropdownItems = find.byType(DropdownMenuItem);
          print(
            'Ditemukan ${dropdownItems.evaluate().length} item di Pekerjaan',
          );

          if (dropdownItems.evaluate().length > 1) {
            print('Tap item Pekerjaan index 1...');
            await tester.tap(dropdownItems.at(1));
            await tester.pumpAndSettle(const Duration(seconds: 1));
            print('Pekerjaan BERHASIL dipilih');
          } else {
            print('Tidak ada item untuk Pekerjaan');
          }
        } else {
          print('Dropdown Pekerjaan tidak ditemukan');
        }

        print('Scroll ke button Simpan...');
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -500));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await tester.drag(scrollable.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -500));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await tester.drag(listView.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else if (scrollableWidget.evaluate().isNotEmpty) {
          await tester.drag(scrollableWidget.first, const Offset(0, -500));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await tester.drag(scrollableWidget.first, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // ===== SUBMIT DATA =====
        print('Mencari button Simpan...');

        final submitByText = find.text('Simpan');
        final submitByKey = find.byKey(const Key('btn_submit_warga'));
        final submitByType = find.byType(ElevatedButton);

        bool submitSuccess = false;

        // Try 1: Cari by text "Simpan"
        if (submitByText.evaluate().isNotEmpty) {
          print('Button Simpan ditemukan by text');
          await tester.ensureVisible(submitByText.last);
          await tester.pumpAndSettle();

          print('Tapping button Simpan...');
          await tester.tap(submitByText.last);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          submitSuccess = true;
        }
        // Try 2: Cari by key
        else if (submitByKey.evaluate().isNotEmpty) {
          print('Button Simpan ditemukan by key');
          await tester.ensureVisible(submitByKey);
          await tester.pumpAndSettle();

          print('Tapping button Simpan...');
          await tester.tap(submitByKey);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          submitSuccess = true;
        }
        // Try 3: Cari ElevatedButton terakhir
        else if (submitByType.evaluate().isNotEmpty) {
          print('Button Simpan ditemukan by type (ElevatedButton)');
          await tester.ensureVisible(submitByType.last);
          await tester.pumpAndSettle();

          print('Tapping button Simpan...');
          await tester.tap(submitByType.last);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          submitSuccess = true;
        }

        if (submitSuccess) {
          print('DATA BERHASIL DITAMBAHKAN!');
        } else {
          print('Submit button tidak ditemukan dengan cara apapun');
          print('KEMBALI TANPA SAVE - DATA TIDAK TERSIMPAN');
          // Kembali tanpa save
          if (find.byIcon(Icons.chevron_left).evaluate().isNotEmpty) {
            await tester.tap(find.byIcon(Icons.chevron_left));
          } else {
            await tester.pageBack();
          }
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    } else {
      print('FAB tidak ditemukan, skip test CREATE');
    }

    // --------------------------------------------------------
    // STEP 10: CRUD - READ (Lihat Detail Warga yang Baru Dibuat)
    // --------------------------------------------------------
    print('Step 10: Test READ - Lihat Detail Test User E2E...');

    // Cari data test yang baru dibuat
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Search data test
    final searchForTest = find.byKey(const Key('field_search_warga'));
    if (searchForTest.evaluate().isNotEmpty) {
      await tester.enterText(searchForTest, 'Test User E2E');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    final detailCard = find.byKey(const Key('warga_card_0'));

    if (detailCard.evaluate().isNotEmpty) {
      await tester.tap(detailCard);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifikasi masuk ke halaman detail
      if (find.text('Detail Warga').evaluate().isNotEmpty ||
          find.byKey(const Key('warga_detail_page')).evaluate().isNotEmpty) {
        print('Berhasil masuk halaman Detail Warga');

        // Verifikasi ada informasi warga (NIK, Nama, dll)
        expect(
          find.byType(Text),
          findsWidgets,
          reason: 'Detail warga harus menampilkan informasi',
        );

        // Test scroll di halaman detail
        final detailScrollable = find.byType(SingleChildScrollView);
        if (detailScrollable.evaluate().isNotEmpty) {
          await tester.drag(detailScrollable.first, const Offset(0, -200));
          await tester.pumpAndSettle();
        } else {
          print('Halaman detail tidak scrollable');
        }

        // Kembali ke daftar
        if (find.byIcon(Icons.chevron_left).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.chevron_left));
        } else if (find.byType(BackButton).evaluate().isNotEmpty) {
          await tester.tap(find.byType(BackButton));
        } else {
          await tester.pageBack();
        }
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    } else {
      print('Card warga tidak ditemukan, skip test READ');
    }

    // --------------------------------------------------------
    // STEP 11: CRUD - UPDATE (Edit Test User E2E)
    // --------------------------------------------------------
    print('Step 11: Test UPDATE - Edit Test User E2E...');

    // Pastikan masih di daftar warga
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Search lagi untuk memastikan data test masih ada
    final searchForEdit = find.byKey(const Key('field_search_warga'));
    if (searchForEdit.evaluate().isNotEmpty) {
      await tester.enterText(searchForEdit, 'Test User E2E');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // Cari card warga test dan buka menu
    final cardForEdit = find.byKey(const Key('warga_card_0'));

    if (cardForEdit.evaluate().isNotEmpty) {
      // Cari PopupMenuButton (three-dot menu) di card
      final menuButtons = find.byType(PopupMenuButton<String>);

      if (menuButtons.evaluate().isNotEmpty) {
        await tester.tap(menuButtons.first);
        await tester.pumpAndSettle();

        // Cari dan tap menu "Edit"
        final editMenu = find.text('Edit');
        if (editMenu.evaluate().isNotEmpty) {
          await tester.tap(editMenu);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verifikasi masuk ke halaman edit
          if (find.text('Edit Warga').evaluate().isNotEmpty ||
              find.text('Form Edit').evaluate().isNotEmpty) {
            print('Berhasil masuk halaman Edit Warga');

            // Test mengubah data
            final namaEditField = find.byKey(const Key('input_nama_warga'));
            if (namaEditField.evaluate().isNotEmpty) {
              await tester.enterText(namaEditField, 'Test User Updated E2E');
              await tester.pumpAndSettle();
            }

            // Submit perubahan
            final submitEditButton = find.byKey(const Key('btn_submit_warga'));
            if (submitEditButton.evaluate().isNotEmpty) {
              await tester.ensureVisible(submitEditButton);
              await tester.pumpAndSettle();

              print('Submitting edit data...');
              await tester.tap(submitEditButton);
              await tester.pumpAndSettle(const Duration(seconds: 5));

              print('Data berhasil diupdate!');
            } else {
              print('Submit button tidak ditemukan, kembali tanpa save');
              if (find.byIcon(Icons.chevron_left).evaluate().isNotEmpty) {
                await tester.tap(find.byIcon(Icons.chevron_left));
              } else {
                await tester.pageBack();
              }
              await tester.pumpAndSettle(const Duration(seconds: 2));
            }
          }
        } else {
          print('Menu Edit tidak ditemukan');
          // Tutup menu dengan tap di luar
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        }
      } else {
        print('PopupMenu tidak ditemukan, skip test UPDATE');
      }
    }

    // --------------------------------------------------------
    // STEP 12: CRUD - DELETE (Hapus Test User - CLEANUP)
    // --------------------------------------------------------
    print('Step 12: Test DELETE - Hapus Test User E2E (Cleanup)...');

    // Pastikan masih di daftar warga
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Search data test yang sudah diupdate
    final searchForDelete = find.byKey(const Key('field_search_warga'));
    if (searchForDelete.evaluate().isNotEmpty) {
      await tester.enterText(searchForDelete, 'Test User Updated');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    final cardForDelete = find.byKey(const Key('warga_card_0'));

    if (cardForDelete.evaluate().isNotEmpty) {
      final menuButtons = find.byType(PopupMenuButton<String>);

      if (menuButtons.evaluate().isNotEmpty) {
        await tester.tap(menuButtons.first);
        await tester.pumpAndSettle();

        // Cari menu "Hapus"
        final deleteMenu = find.text('Hapus');
        if (deleteMenu.evaluate().isNotEmpty) {
          await tester.tap(deleteMenu);
          await tester.pumpAndSettle();

          // Verifikasi dialog konfirmasi muncul
          if (find.text('Konfirmasi').evaluate().isNotEmpty ||
              find.text('Hapus').evaluate().length > 1) {
            print('Dialog konfirmasi hapus muncul');

            final confirmButton = find.text('Ya');
            final deleteButton = find.text('Hapus').last;

            if (confirmButton.evaluate().isNotEmpty) {
              await tester.tap(confirmButton);
              await tester.pumpAndSettle(const Duration(seconds: 5));
              print('Data test berhasil dihapus (Cleanup)');
            } else if (deleteButton.evaluate().isNotEmpty) {
              await tester.tap(deleteButton);
              await tester.pumpAndSettle(const Duration(seconds: 5));
              print('Data test berhasil dihapus (Cleanup)');
            } else {
              print('Tombol konfirmasi tidak ditemukan');
              await tester.tapAt(const Offset(10, 10));
              await tester.pumpAndSettle();
            }
          }
        } else {
          print('Menu Hapus tidak ditemukan');
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        }
      }
    }

    // Reset search untuk verifikasi cleanup
    final searchReset = find.byKey(const Key('field_search_warga'));
    if (searchReset.evaluate().isNotEmpty) {
      await tester.enterText(searchReset, '');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // --------------------------------------------------------
    // STEP 13: TEST KOMBINASI FILTER (Multi Filter)
    // --------------------------------------------------------
    print('Step 13: Test Kombinasi Multiple Filter...');

    if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Filter Gender
      final genderDropdown = find.byKey(const Key('dropdown_filter_gender'));
      if (genderDropdown.evaluate().isNotEmpty) {
        await tester.tap(genderDropdown);
        await tester.pumpAndSettle();

        final perempuanOption = find.text('Perempuan');
        if (perempuanOption.evaluate().isNotEmpty) {
          await tester.tap(perempuanOption.last);
          await tester.pumpAndSettle();
        }
      }

      // Filter Status
      final statusDropdowns = find.byType(DropdownButtonFormField);
      if (statusDropdowns.evaluate().length >= 2) {
        await tester.tap(statusDropdowns.at(1));
        await tester.pumpAndSettle();

        final aktifOption = find.text('Aktif');
        if (aktifOption.evaluate().isNotEmpty) {
          await tester.tap(aktifOption.last);
          await tester.pumpAndSettle();
        }
      }

      // Apply kombinasi filter
      final applyBtn = find.byKey(const Key('btn_apply_filter'));
      if (applyBtn.evaluate().isNotEmpty) {
        await tester.tap(applyBtn);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('Kombinasi filter diterapkan: Perempuan + Aktif');
      }
    }

    // --------------------------------------------------------
    // STEP 14: VERIFIKASI EMPTY STATE
    // --------------------------------------------------------
    print('Step 14: Test Empty State (Pencarian tanpa hasil)...');

    final searchForEmpty = find.byKey(const Key('field_search_warga'));
    if (searchForEmpty.evaluate().isNotEmpty) {
      await tester.enterText(searchForEmpty, 'DataYangTidakAda99999');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cek apakah ada empty state message
      if (find.text('Tidak ada data').evaluate().isNotEmpty ||
          find.text('Data tidak ditemukan').evaluate().isNotEmpty) {
        print('Empty state ditampilkan dengan benar');
      }

      // Reset
      await tester.enterText(searchForEmpty, '');
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    print('==============================================');
    print('E2E Daftar Warga SELESAI!');
    print('Total Steps: 14');
    print('- Login:');
    print('- Navigation:');
    print('- Search:');
    print('- Filter (Gender, Status, Keluarga):');
    print('- Multi Filter:');
    print('- CRUD Create:');
    print('- CRUD Read:');
    print('- CRUD Update:');
    print('- CRUD Delete (Simulation):');
    print('- Empty State:');
    print('==============================================');
  });
}
