import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/aspirasi_model.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/broadcast_model.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/kegiatan_model.dart';
// Models
import 'package:jawara_pintar_kel_5/models/keluarga/anggota_keluarga_model.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/channel_transfer_model.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/transaksi_model.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/warga_tagihan_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/marketplace_model.dart'
    as m_model;
import 'package:jawara_pintar_kel_5/models/marketplace/order_model.dart'
    as o_model;
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
// Broadcast
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/broadcast/daftar_broadcast.dart';
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/broadcast/detail_broadcast_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/broadcast/edit_broadcast_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/broadcast/tambah_broadcast.dart';
// Kegiatan
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/kegiatan/daftar_kegiatan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/kegiatan/detail_kegiatan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/kegiatan/edit_kegiatan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/kegiatan/tambah_kegiatan_screen.dart';
// ========================= KEGIATAN =========================
// Menu
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/kegiatan_screen.dart';
// Log Aktivitas
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/logaktivitas/logaktivitas_admin.dart';
// Pesan Warga
import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/pesanwarga/pesanwarga_tab.dart';
// ========================= KEUANGAN =========================
import 'package:jawara_pintar_kel_5/screens/admin/keuangan/keuangan_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keuangan/laporan_keuangan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keuangan/pengeluaran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/channel_transfer/detail_channel.dart';
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/channel_transfer/edit_channel.dart';
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/channel_transfer/tambah_channel.dart';
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/edit_profile_screen.dart';
// ========================= LAINNYA =========================
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/lainnya_menu_screen.dart';
// Channel Transfer
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/manajemen_channel_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/manajemen_pengguna_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/pengguna/detail_pengguna.dart';
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/pengguna/edit_pengguna.dart';
// Pengguna
import 'package:jawara_pintar_kel_5/screens/admin/lainnya/pengguna/tambah_pengguna.dart';
// ========================= LAPORAN =========================
import 'package:jawara_pintar_kel_5/screens/admin/laporan/cetak_laporan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/laporan/pemasukan_lain_tambah_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/laporan/semua_pemasukan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/laporan/semua_pengeluaran_screen.dart';
// Layout
import 'package:jawara_pintar_kel_5/screens/admin/layout.dart';
import 'package:jawara_pintar_kel_5/screens/admin/marketplace/menu_marketplace.dart';
import 'package:jawara_pintar_kel_5/screens/admin/marketplace/validasi_akun.dart';
import 'package:jawara_pintar_kel_5/screens/admin/marketplace/validasiproduk.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pemasukan/detail_pemasukan_lain_screen.dart';
// Pemasukan
import 'package:jawara_pintar_kel_5/screens/admin/pemasukan/kategori_iuran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pemasukan/pemasukan_lain_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pemasukan/pemasukan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pemasukan/tagih_iuran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pemasukan/tagihan_screen.dart';
// Keluarga
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/keluarga/daftar_keluarga.dart'
    hide Keluarga;
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/keluarga/daftar_mutasi_keluarga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/keluarga/detail_keluarga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/keluarga/tambah_mutasi_keluarga.dart';
// ========================= PENDUDUK =========================
// Menu umum
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penduduk_menu_screen.dart';
// Penerimaan Warga
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/detail_penerimaan_warga.dart';
// Rumah
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/daftar_rumah.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/detail_rumah.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/edit_rumah.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/tambah_rumah.dart';
// Warga
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/daftar_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/detail_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/edit_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/tambah_warga.dart';
// Pengeluaran
import 'package:jawara_pintar_kel_5/screens/admin/pengeluaran/daftar_pengeluaran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pengeluaran/tambah_pengeluaran_screen.dart';
// Auth
import 'package:jawara_pintar_kel_5/screens/auth/login.dart';
import 'package:jawara_pintar_kel_5/screens/auth/register.dart';
import 'package:jawara_pintar_kel_5/screens/bendahara/keuangan/keuangan_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/bendahara/lainnya/lainnya_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/bendahara/layout.dart';
import 'package:jawara_pintar_kel_5/screens/rt/keuangan/keuangan_menu_screen.dart';
// RT & RW
import 'package:jawara_pintar_kel_5/screens/rt/lainnya/lainnya_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/rt/layout.dart';
import 'package:jawara_pintar_kel_5/screens/rt/penduduk/penduduk_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/rw/keuangan/keuangan_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/rw/lainnya/lainnya_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/rw/layout.dart';
import 'package:jawara_pintar_kel_5/screens/rw/penduduk/penduduk_menu_screen.dart';
// Sekretaris & Bendahara
import 'package:jawara_pintar_kel_5/screens/sekretaris/kegiatan/kegiatan_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/sekretaris/lainnya/lainnya_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/sekretaris/layout.dart';
// Dashboard
import 'package:jawara_pintar_kel_5/screens/warga/dashboard/dashboard.dart';
import 'package:jawara_pintar_kel_5/screens/warga/dashboard/detail_laporan_pemasukan.dart';
import 'package:jawara_pintar_kel_5/screens/warga/dashboard/detail_laporan_pengeluaran.dart';
import 'package:jawara_pintar_kel_5/screens/warga/dashboard/laporanpemasukan.dart';
import 'package:jawara_pintar_kel_5/screens/warga/dashboard/laporanpengeluaran.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/aspirasiwarga/daftar_aspirasi.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/aspirasiwarga/detail_aspirasi.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/broadcashwarga/broadcash_warga.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/broadcashwarga/detailBroadcash.dart';
// Kegiatan
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kegiatan_menu.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kegiatanwarga/daftarkegiatanwarga.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kegiatanwarga/detailkegiatan.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kirimansaya/daftar_kiriman.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kirimansaya/detail_kiriman.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kirimansaya/edit_kiriman.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kirimansaya/tambah_aspirasi.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/daftar_anggota.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/detail_anggota.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/detail_tagihan.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/edit_anggota.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/form_pembayaran.dart';
// Keluarga
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/keluarga_menu.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/profilkeluarga.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/tagihan.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/tambah_anggota.dart';
// +++++++++++  WARGA   +++++++++++
// layout
import 'package:jawara_pintar_kel_5/screens/warga/layout_warga.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/buyer_order_detail.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/checkoutscreen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/detail_produk.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/filterScreen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/homepage.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/keranjangScreen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/my_orders.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/orderhistoryScreen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/riview_produk.dart';
// marketplace
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/marketplace_menu.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/auth_store.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/buat_akun_toko.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/detail_orders.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/edit_produk.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/editprofile_toko.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/login_akun.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/pending_deactivation.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/pengaturanstore.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/pesanan_store.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/review_store.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/stok_produk_store.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/store_dashboard.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/store_pending_validasi.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/store_product_detail.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/tokoSaya/tambah_produk.dart';
// Profil
import 'package:jawara_pintar_kel_5/screens/warga/profil/profil_menu.dart';
import 'package:jawara_pintar_kel_5/screens/warga/profil/profil_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/profil/edit_profil.dart';
import 'package:jawara_pintar_kel_5/screens/warga/profil/pusat_bantuan.dart';
import 'package:jawara_pintar_kel_5/screens/warga/profil/pengaturan_akun.dart';
import 'package:jawara_pintar_kel_5/screens/warga/profil/reset_pw_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/profil/tentang_apk.dart';

// ================= Dummy Class (Placeholder) =================
class DetailValidasiProdukScreen extends StatelessWidget {
  final dynamic product;
  const DetailValidasiProdukScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Detail Validasi Produk (Placeholder)')),
    );
  }
}
// =============================================================

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: "/login",
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/login'),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegisterScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdminLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/penduduk',
              name: 'pendudukMenu',
              builder: (context, state) => const DashboardPendudukPage(),
              routes: [
                GoRoute(
                  path: 'daftar-warga',
                  name: 'wargaList',
                  builder: (context, state) => const DaftarWargaPage(),
                ),
                GoRoute(
                  path: 'daftar-rumah',
                  name: 'rumahList',
                  builder: (context, state) => const DaftarRumahPage(),
                ),
                GoRoute(
                  path: 'tambah-rumah',
                  name: 'rumahAdd',
                  builder: (context, state) => const TambahRumahPage(),
                ),
                GoRoute(
                  path: 'detail-rumah',
                  name: 'rumahDetail',
                  builder: (context, state) {
                    final rumah = state.extra as Rumah;
                    return DetailRumahPage(rumah: rumah);
                  },
                ),
                GoRoute(
                  path: 'edit-rumah',
                  name: 'rumahEdit',
                  builder: (context, state) {
                    final rumah = state.extra as Rumah;
                    return EditRumahPage(rumah: rumah);
                  },
                ),
                GoRoute(
                  path: 'detail-warga',
                  name: 'wargaDetail',
                  builder: (context, state) {
                    final data = state.extra as Warga;
                    return DetailWargaPage(warga: data);
                  },
                ),
                GoRoute(
                  path: 'tambah-warga',
                  name: 'wargaAdd',
                  builder: (context, state) => const TambahWargaPage(),
                ),
                GoRoute(
                  path: 'edit-warga',
                  name: 'wargaEdit',
                  builder: (context, state) {
                    final data = state.extra as Warga;
                    return EditWargaPage(warga: data);
                  },
                ),
                GoRoute(
                  path: 'daftar-penerimaan',
                  name: 'penerimaanList',
                  builder: (context, state) =>
                      const DaftarPenerimaanWargaPage(),
                ),
                GoRoute(
                  path: 'detail-penerimaan',
                  name: 'penerimaanDetail',
                  builder: (context, state) {
                    final penerimaan = state.extra as PenerimaanWarga;
                    return DetailPenerimaanWargaPage(penerimaan: penerimaan);
                  },
                ),
                GoRoute(
                  path: 'daftar-keluarga',
                  name: 'keluargaList',
                  builder: (context, state) => const DaftarKeluargaPage(),
                ),
                GoRoute(
                  path: 'detail-keluarga',
                  name: 'keluargaDetail',
                  builder: (context, state) {
                    final keluarga = state.extra as dynamic;
                    return DetailKeluargaPage(keluarga: keluarga);
                  },
                ),
                GoRoute(
                  path: 'daftar-mutasi-keluarga',
                  name: 'mutasiKeluargaList',
                  builder: (context, state) => const DaftarMutasiKeluargaPage(),
                ),
                GoRoute(
                  path: 'tambah-mutasi-keluarga',
                  name: 'mutasiKeluargaAdd',
                  builder: (context, state) => const TambahMutasiKeluargaPage(),
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/keuangan',
              builder: (context, state) => const Keuangan(),
            ),
            GoRoute(
              path: '/admin/pemasukan',
              builder: (context, state) => const PemasukanScreen(),
            ),
            GoRoute(
              path: '/admin/pengeluaran',
              builder: (context, state) => const PengeluaranScreen(),
            ),
            GoRoute(
              path: '/admin/laporan-keuangan',
              builder: (context, state) => const LaporanKeuanganScreen(),
            ),
            GoRoute(
              path: '/admin/pemasukan/kategori-iuran',
              builder: (context, state) => const KategoriIuranScreen(),
            ),
            GoRoute(
              path: '/admin/pemasukan/tagih-iuran',
              builder: (context, state) => const TagihIuranScreen(),
            ),
            GoRoute(
              path: '/admin/pemasukan/tagihan',
              builder: (context, state) => const TagihanScreen(),
            ),
            GoRoute(
              path: '/admin/pemasukan/pemasukan-lain',
              builder: (context, state) => const PemasukanLainScreen(),
            ),
            GoRoute(
              path: '/admin/pemasukan/pemasukan-lain-detail',
              builder: (context, state) {
                final data = state.extra as PemasukanLainModel;
                return DetailPemasukanLainScreen(data: data);
              },
            ),
            GoRoute(
              path: '/admin/pemasukan/pemasukan-lain-tambah',
              builder: (context, state) => const PemasukanLainTambahScreen(),
            ),
            // Pengeluaran routes
            GoRoute(
              path: '/admin/pengeluaran/daftar',
              builder: (context, state) => const DaftarPengeluaranScreen(),
            ),
            GoRoute(
              path: '/admin/pengeluaran/tambah',
              builder: (context, state) => const TambahPengeluaranScreen(),
            ),
            // Laporan routes
            GoRoute(
              path: '/admin/laporan/semua-pemasukan',
              builder: (context, state) => const SemuaPemasukanScreen(),
            ),
            GoRoute(
              path: '/admin/laporan/semua-pengeluaran',
              builder: (context, state) => const SemuaPengeluaranScreen(),
            ),
            GoRoute(
              path: '/admin/laporan/cetak-laporan',
              builder: (context, state) => const CetakLaporanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/marketplace',
              name: 'marketplaceMenu',
              builder: (context, state) => const Marketplace(),
            ),
            GoRoute(
              path: '/admin/marketplace/validasiproduk',
              name: 'validasiProdukList',
              builder: (context, state) => const ValidasiProdukBaruScreen(),
            ),
            GoRoute(
              path: '/admin/marketplace/validasiakuntoko',
              name: 'validasiAkunToko',
              builder: (context, state) => const ValidasiAkunTokoScreen(),
            ),
            GoRoute(
              path: '/admin/marketplace/detail',
              name: 'detailValidasiProduk',
              builder: (context, state) {
                final product = state.extra as m_model.ActiveProductItem;
                return DetailValidasiProdukScreen(product: product);
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/kegiatan',
              name: 'kegiatanMenu',
              builder: (context, state) => const KegiatanScreen(),
              routes: [
                GoRoute(
                  path: 'daftar',
                  builder: (context, state) => const DaftarKegiatanScreen(),
                ),
                GoRoute(
                  path: 'tambah',
                  builder: (context, state) => const TambahKegiatanScreen(),
                ),
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final kegiatan = state.extra as KegiatanModel;
                    return DetailKegiatanScreen(kegiatan: kegiatan);
                  },
                ),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final kegiatan = state.extra as KegiatanModel;
                    return EditKegiatanScreen(kegiatan: kegiatan);
                  },
                ),
                GoRoute(
                  path: 'broadcast/daftar',
                  name: 'broadcastDaftar',
                  builder: (context, state) => const DaftarBroadcastScreen(),
                ),
                GoRoute(
                  path: 'broadcast/tambah',
                  name: 'broadcastTambah',
                  builder: (context, state) => const TambahBroadcastScreen(),
                ),
                GoRoute(
                  path: 'broadcast/detail',
                  name: 'broadcastDetail',
                  builder: (context, state) {
                    final broadcast = state.extra as BroadcastModel;
                    return DetailBroadcastScreen(broadcastModel: broadcast);
                  },
                ),
                GoRoute(
                  path: 'broadcast/edit',
                  name: 'broadcastEdit',
                  builder: (context, state) {
                    final broadcast = state.extra as BroadcastModel;
                    return EditBroadcastScreen(broadcast: broadcast);
                  },
                ),
                GoRoute(
                  path: 'pesanwarga',
                  name: 'pesanWarga',
                  builder: (context, state) => const PesanWargaScreen(),
                ),
                GoRoute(
                  path: 'logaktivitas',
                  name: 'logAktivitas',
                  builder: (context, state) => const LogAktivitasScreenAdmin(),
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/lainnya',
              builder: (context, state) => LainnyaScreen(),
            ),
            GoRoute(
              path: '/admin/lainnya/edit-profile',
              name: 'adminEditProfile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: '/admin/lainnya/manajemen-pengguna',
              builder: (context, state) => const ManajemenPenggunaScreen(),
            ),
            GoRoute(
              path: '/admin/lainnya/manajemen-pengguna/tambah',
              builder: (context, state) => const TambahPenggunaScreen(),
            ),
            GoRoute(
              path: '/admin/lainnya/manajemen-pengguna/detail',
              name: 'penggunaDetail',
              builder: (context, state) {
                final userdata = state.extra as Map<String, String>? ?? {};
                return DetailPenggunaScreen(userData: userdata);
              },
            ),
            GoRoute(
              path: '/admin/lainnya/manajemen-pengguna/edit',
              name: 'penggunaEdit',
              builder: (context, state) {
                final userdata = state.extra as Map<String, String>? ?? {};
                return EditPenggunaScreen(userData: userdata);
              },
            ),
            GoRoute(
              path: '/admin/lainnya/manajemen-channel',
              builder: (context, state) => const ChannelTransferScreen(),
            ),
            GoRoute(
              path: '/admin/lainnya/manajemen-channel/tambah',
              builder: (context, state) => const TambahChannelPage(),
            ),
            GoRoute(
              path: '/admin/lainnya/channel-transfer/detail',
              builder: (context, state) {
                final channelData = state.extra as ChannelTransferModel;
                return DetailChannelPage(channel: channelData);
              },
            ),
            GoRoute(
              path: '/admin/lainnya/channel-transfer/edit',
              builder: (context, state) {
                final channelData = state.extra as ChannelTransferModel;
                return EditChannelPage(channelData: channelData);
              },
            ),
          ],
        ),
      ],
    ),
    // ========================= RT ROUTES =========================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RTLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rt/penduduk',
              name: 'rt_penduduk',
              builder: (context, state) => const RTMenuPenduduk(),
              routes: [
                GoRoute(
                  path: 'daftar-warga',
                  name: 'rt_wargaList',
                  builder: (context, state) => const DaftarWargaPage(),
                ),
                GoRoute(
                  path: 'daftar-rumah',
                  name: 'rt_rumahList',
                  builder: (context, state) => const DaftarRumahPage(),
                ),
                GoRoute(
                  path: 'detail-rumah',
                  name: 'rt_rumahDetail',
                  builder: (context, state) {
                    final rumah = state.extra as Rumah;
                    return DetailRumahPage(rumah: rumah);
                  },
                ),
                GoRoute(
                  path: 'detail-warga',
                  name: 'rt_wargaDetail',
                  builder: (context, state) {
                    final data = state.extra as Warga;
                    return DetailWargaPage(warga: data);
                  },
                ),
                GoRoute(
                  path: 'daftar-keluarga',
                  name: 'rt_keluargaList',
                  builder: (context, state) => const DaftarKeluargaPage(),
                ),
                GoRoute(
                  path: 'detail-keluarga',
                  name: 'rt_keluargaDetail',
                  builder: (context, state) {
                    final keluarga = state.extra as dynamic;
                    return DetailKeluargaPage(keluarga: keluarga);
                  },
                ),
                GoRoute(
                  path: 'daftar-mutasi-keluarga',
                  name: 'rt_mutasiKeluargaList',
                  builder: (context, state) => const DaftarMutasiKeluargaPage(),
                ),
                GoRoute(
                  path: 'daftar-penerimaan',
                  name: 'rt_penerimaanList',
                  builder: (context, state) =>
                      const DaftarPenerimaanWargaPage(),
                ),
                GoRoute(
                  path: 'detail-penerimaan',
                  name: 'rt_penerimaanDetail',
                  builder: (context, state) {
                    final data = state.extra as PenerimaanWarga;
                    return DetailPenerimaanWargaPage(penerimaan: data);
                  },
                ),
                GoRoute(
                  path: 'daftar-kegiatan',
                  name: 'rt_kegiatanList',
                  builder: (context, state) => const DaftarKegiatanScreen(),
                ),
                GoRoute(
                  path: 'detail-kegiatan',
                  name: 'rt_kegiatanDetail',
                  builder: (context, state) {
                    final kegiatan = state.extra as KegiatanModel;
                    return DetailKegiatanScreen(kegiatan: kegiatan);
                  },
                ),
                GoRoute(
                  path: 'daftar-broadcast',
                  name: 'rt_broadcastList',
                  builder: (context, state) => const DaftarBroadcastScreen(),
                ),
                GoRoute(
                  path: 'detail-broadcast',
                  name: 'rt_broadcastDetail',
                  builder: (context, state) {
                    final broadcast = state.extra as BroadcastModel;
                    return DetailBroadcastScreen(broadcastModel: broadcast);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rt/keuangan',
              name: 'rt_keuangan',
              builder: (context, state) => const RTMenuKeuangan(),
              routes: [
                GoRoute(
                  path: 'kategori-iuran',
                  name: 'rt_kategoriIuran',
                  builder: (context, state) => const KategoriIuranScreen(),
                ),
                GoRoute(
                  path: 'tagih-iuran',
                  name: 'rt_tagihIuran',
                  builder: (context, state) => const TagihIuranScreen(),
                ),
                GoRoute(
                  path: 'tagihan',
                  name: 'rt_tagihan',
                  builder: (context, state) => const TagihanScreen(),
                ),
                GoRoute(
                  path: 'pemasukan-lain',
                  name: 'rt_pemasukanLain',
                  builder: (context, state) => const PemasukanLainScreen(),
                ),
                GoRoute(
                  path: 'daftar-pengeluaran',
                  name: 'rt_pengeluaranList',
                  builder: (context, state) => const DaftarPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'laporan-pemasukan',
                  name: 'rt_laporanPemasukan',
                  builder: (context, state) => const SemuaPemasukanScreen(),
                ),
                GoRoute(
                  path: 'laporan-pengeluaran',
                  name: 'rt_laporanPengeluaran',
                  builder: (context, state) => const SemuaPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'cetak-laporan',
                  name: 'rt_cetakLaporan',
                  builder: (context, state) => const CetakLaporanScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rt/lainnya',
              name: 'rt_lainnya',
              builder: (context, state) => const RTMenuLainnya(),
              routes: [
                GoRoute(
                  path: 'pesan-warga',
                  name: 'rt_pesanWarga',
                  builder: (context, state) => const PesanWargaScreen(),
                ),
                GoRoute(
                  path: 'log-aktivitas',
                  name: 'rt_logAktivitas',
                  builder: (context, state) => const LogAktivitasScreenAdmin(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // ========================= RW ROUTES =========================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RWLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rw/penduduk',
              name: 'rw_penduduk',
              builder: (context, state) => const RWMenuPenduduk(),
              routes: [
                GoRoute(
                  path: 'daftar-warga',
                  name: 'rw_wargaList',
                  builder: (context, state) => const DaftarWargaPage(),
                ),
                GoRoute(
                  path: 'daftar-rumah',
                  name: 'rw_rumahList',
                  builder: (context, state) => const DaftarRumahPage(),
                ),
                GoRoute(
                  path: 'detail-rumah',
                  name: 'rw_rumahDetail',
                  builder: (context, state) {
                    final rumah = state.extra as Rumah;
                    return DetailRumahPage(rumah: rumah);
                  },
                ),
                GoRoute(
                  path: 'tambah-rumah',
                  name: 'rw_rumahAdd',
                  builder: (context, state) => const TambahRumahPage(),
                ),
                GoRoute(
                  path: 'edit-rumah',
                  name: 'rw_rumahEdit',
                  builder: (context, state) {
                    final rumah = state.extra as Rumah;
                    return EditRumahPage(rumah: rumah);
                  },
                ),
                GoRoute(
                  path: 'detail-warga',
                  name: 'rw_wargaDetail',
                  builder: (context, state) {
                    final data = state.extra as Warga;
                    return DetailWargaPage(warga: data);
                  },
                ),
                GoRoute(
                  path: 'tambah-warga',
                  name: 'rw_wargaAdd',
                  builder: (context, state) => const TambahWargaPage(),
                ),
                GoRoute(
                  path: 'edit-warga',
                  name: 'rw_wargaEdit',
                  builder: (context, state) {
                    final data = state.extra as Warga;
                    return EditWargaPage(warga: data);
                  },
                ),
                GoRoute(
                  path: 'daftar-keluarga',
                  name: 'rw_keluargaList',
                  builder: (context, state) => const DaftarKeluargaPage(),
                ),
                GoRoute(
                  path: 'detail-keluarga',
                  name: 'rw_keluargaDetail',
                  builder: (context, state) {
                    final keluarga = state.extra as dynamic;
                    return DetailKeluargaPage(keluarga: keluarga);
                  },
                ),
                GoRoute(
                  path: 'daftar-mutasi-keluarga',
                  name: 'rw_mutasiKeluargaList',
                  builder: (context, state) => const DaftarMutasiKeluargaPage(),
                ),
                GoRoute(
                  path: 'tambah-mutasi-keluarga',
                  name: 'rw_mutasiKeluargaAdd',
                  builder: (context, state) => const TambahMutasiKeluargaPage(),
                ),
                GoRoute(
                  path: 'daftar-penerimaan',
                  name: 'rw_penerimaanList',
                  builder: (context, state) =>
                      const DaftarPenerimaanWargaPage(),
                ),
                GoRoute(
                  path: 'detail-penerimaan',
                  name: 'rw_penerimaanDetail',
                  builder: (context, state) {
                    final data = state.extra as PenerimaanWarga;
                    return DetailPenerimaanWargaPage(penerimaan: data);
                  },
                ),
                GoRoute(
                  path: 'daftar-kegiatan',
                  name: 'rw_kegiatanList',
                  builder: (context, state) => const DaftarKegiatanScreen(),
                ),
                GoRoute(
                  path: 'detail-kegiatan',
                  name: 'rw_kegiatanDetail',
                  builder: (context, state) {
                    final kegiatan = state.extra as KegiatanModel;
                    return DetailKegiatanScreen(kegiatan: kegiatan);
                  },
                ),
                GoRoute(
                  path: 'tambah-kegiatan',
                  name: 'rw_kegiatanAdd',
                  builder: (context, state) => const TambahKegiatanScreen(),
                ),
                GoRoute(
                  path: 'edit-kegiatan',
                  name: 'rw_kegiatanEdit',
                  builder: (context, state) {
                    final kegiatan = state.extra as KegiatanModel;
                    return EditKegiatanScreen(kegiatan: kegiatan);
                  },
                ),
                GoRoute(
                  path: 'daftar-broadcast',
                  name: 'rw_broadcastList',
                  builder: (context, state) => const DaftarBroadcastScreen(),
                ),
                GoRoute(
                  path: 'detail-broadcast',
                  name: 'rw_broadcastDetail',
                  builder: (context, state) {
                    final broadcast = state.extra as BroadcastModel;
                    return DetailBroadcastScreen(broadcastModel: broadcast);
                  },
                ),
                GoRoute(
                  path: 'tambah-broadcast',
                  name: 'rw_broadcastAdd',
                  builder: (context, state) => const TambahBroadcastScreen(),
                ),
                GoRoute(
                  path: 'edit-broadcast',
                  name: 'rw_broadcastEdit',
                  builder: (context, state) {
                    final broadcast = state.extra as BroadcastModel;
                    return EditBroadcastScreen(broadcast: broadcast);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rw/keuangan',
              name: 'rw_keuangan',
              builder: (context, state) => const RWMenuKeuangan(),
              routes: [
                GoRoute(
                  path: 'kategori-iuran',
                  name: 'rw_kategoriIuran',
                  builder: (context, state) => const KategoriIuranScreen(),
                ),
                GoRoute(
                  path: 'tagih-iuran',
                  name: 'rw_tagihIuran',
                  builder: (context, state) => const TagihIuranScreen(),
                ),
                GoRoute(
                  path: 'tagihan',
                  name: 'rw_tagihan',
                  builder: (context, state) => const TagihanScreen(),
                ),
                GoRoute(
                  path: 'pemasukan-lain',
                  name: 'rw_pemasukanLain',
                  builder: (context, state) => const PemasukanLainScreen(),
                ),
                GoRoute(
                  path: 'tambah-pemasukan-lain',
                  name: 'rw_pemasukanLainAdd',
                  builder: (context, state) =>
                      const PemasukanLainTambahScreen(),
                ),
                GoRoute(
                  path: 'daftar-pengeluaran',
                  name: 'rw_pengeluaranList',
                  builder: (context, state) => const DaftarPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'tambah-pengeluaran',
                  name: 'rw_pengeluaranAdd',
                  builder: (context, state) => const TambahPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'laporan-pemasukan',
                  name: 'rw_laporanPemasukan',
                  builder: (context, state) => const SemuaPemasukanScreen(),
                ),
                GoRoute(
                  path: 'laporan-pengeluaran',
                  name: 'rw_laporanPengeluaran',
                  builder: (context, state) => const SemuaPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'cetak-laporan',
                  name: 'rw_cetakLaporan',
                  builder: (context, state) => const CetakLaporanScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rw/lainnya',
              name: 'rw_lainnya',
              builder: (context, state) => const RWMenuLainnya(),
              routes: [
                GoRoute(
                  path: 'pesan-warga',
                  name: 'rw_pesanWarga',
                  builder: (context, state) => const PesanWargaScreen(),
                ),
                GoRoute(
                  path: 'log-aktivitas',
                  name: 'rw_logAktivitas',
                  builder: (context, state) => const LogAktivitasScreenAdmin(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // ========================= SEKRETARIS ROUTES =========================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          SekretarisLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sekretaris/kegiatan',
              name: 'sekretaris_kegiatan',
              builder: (context, state) => const SekretarisMenuKegiatan(),
              routes: [
                GoRoute(
                  path: 'daftar-kegiatan',
                  name: 'sekretaris_kegiatanList',
                  builder: (context, state) => const DaftarKegiatanScreen(),
                ),
                GoRoute(
                  path: 'detail-kegiatan',
                  name: 'sekretaris_kegiatanDetail',
                  builder: (context, state) {
                    final kegiatan = state.extra as KegiatanModel;
                    return DetailKegiatanScreen(kegiatan: kegiatan);
                  },
                ),
                GoRoute(
                  path: 'tambah-kegiatan',
                  name: 'sekretaris_kegiatanAdd',
                  builder: (context, state) => const TambahKegiatanScreen(),
                ),
                GoRoute(
                  path: 'edit-kegiatan',
                  name: 'sekretaris_kegiatanEdit',
                  builder: (context, state) {
                    final kegiatan = state.extra as KegiatanModel;
                    return EditKegiatanScreen(kegiatan: kegiatan);
                  },
                ),
                GoRoute(
                  path: 'daftar-broadcast',
                  name: 'sekretaris_broadcastList',
                  builder: (context, state) => const DaftarBroadcastScreen(),
                ),
                GoRoute(
                  path: 'detail-broadcast',
                  name: 'sekretaris_broadcastDetail',
                  builder: (context, state) {
                    final broadcast = state.extra as BroadcastModel;
                    return DetailBroadcastScreen(broadcastModel: broadcast);
                  },
                ),
                GoRoute(
                  path: 'tambah-broadcast',
                  name: 'sekretaris_broadcastAdd',
                  builder: (context, state) => const TambahBroadcastScreen(),
                ),
                GoRoute(
                  path: 'edit-broadcast',
                  name: 'sekretaris_broadcastEdit',
                  builder: (context, state) {
                    final broadcast = state.extra as BroadcastModel;
                    return EditBroadcastScreen(broadcast: broadcast);
                  },
                ),
                GoRoute(
                  path: 'log-aktivitas',
                  name: 'sekretaris_logAktivitas',
                  builder: (context, state) => const LogAktivitasScreenAdmin(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sekretaris/lainnya',
              name: 'sekretaris_lainnya',
              builder: (context, state) => const SekretarisMenuLainnya(),
            ),
          ],
        ),
      ],
    ),
    // ========================= BENDAHARA ROUTES =========================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          BendaharaLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bendahara/keuangan',
              name: 'bendahara_keuangan',
              builder: (context, state) => const BendaharaMenuKeuangan(),
              routes: [
                GoRoute(
                  path: 'kategori-iuran',
                  name: 'bendahara_kategoriIuran',
                  builder: (context, state) => const KategoriIuranScreen(),
                ),
                GoRoute(
                  path: 'tagih-iuran',
                  name: 'bendahara_tagihIuran',
                  builder: (context, state) => const TagihIuranScreen(),
                ),
                GoRoute(
                  path: 'tagihan',
                  name: 'bendahara_tagihan',
                  builder: (context, state) => const TagihanScreen(),
                ),
                GoRoute(
                  path: 'pemasukan-lain',
                  name: 'bendahara_pemasukanLain',
                  builder: (context, state) => const PemasukanLainScreen(),
                ),
                GoRoute(
                  path: 'tambah-pemasukan-lain',
                  name: 'bendahara_pemasukanLainAdd',
                  builder: (context, state) =>
                      const PemasukanLainTambahScreen(),
                ),
                GoRoute(
                  path: 'pemasukan-lain-detail',
                  name: 'bendahara_pemasukanLainDetail',
                  builder: (context, state) {
                    final data = state.extra as PemasukanLainModel;
                    return DetailPemasukanLainScreen(data: data);
                  },
                ),
                GoRoute(
                  path: 'daftar-pengeluaran',
                  name: 'bendahara_pengeluaranList',
                  builder: (context, state) => const DaftarPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'tambah-pengeluaran',
                  name: 'bendahara_pengeluaranAdd',
                  builder: (context, state) => const TambahPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'laporan-pemasukan',
                  name: 'bendahara_laporanPemasukan',
                  builder: (context, state) => const SemuaPemasukanScreen(),
                ),
                GoRoute(
                  path: 'laporan-pengeluaran',
                  name: 'bendahara_laporanPengeluaran',
                  builder: (context, state) => const SemuaPengeluaranScreen(),
                ),
                GoRoute(
                  path: 'cetak-laporan',
                  name: 'bendahara_cetakLaporan',
                  builder: (context, state) => const CetakLaporanScreen(),
                ),
                GoRoute(
                  path: 'channel-transfer',
                  name: 'bendahara_channelList',
                  builder: (context, state) => const ChannelTransferScreen(),
                ),
                GoRoute(
                  path: 'channel-transfer/tambah',
                  name: 'bendahara_channelAdd',
                  builder: (context, state) => const TambahChannelPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bendahara/lainnya',
              name: 'bendahara_lainnya',
              builder: (context, state) => const BendaharaMenuLainnya(),
            ),
          ],
        ),
      ],
    ),
    //------------------WARGA-----------------------
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          WargaLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/warga/dashboard',
              name: 'WargaRumah',
              builder: (context, state) => const RumahDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'pemasukan',
                  name: 'SemuaPemasukanWarga',
                  builder: (context, state) =>
                      const SemuaPemasukanWargaScreen(),
                  routes: [
                    GoRoute(
                      path: 'detailpemasukan',
                      name: 'DetailPemasukanWarga',
                      builder: (context, state) {
                        final data = state.extra as TransaksiModel;
                        return LaporanDetailPemasukanScreen(data: data);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'pengeluaran',
                  name: 'SemuaPengeluaranWarga',
                  builder: (context, state) =>
                      const SemuaPengeluaranWargaScreen(),
                  routes: [
                    GoRoute(
                      path: 'detailpengeluaran',
                      name: 'DetailPengeluaranWarga',
                      builder: (context, state) {
                        final data = state.extra as TransaksiModel;
                        return LaporanDetailPengeluaranScreen(data: data);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/warga/keluarga',
              name: 'WargaKeluarga',
              builder: (context, state) => const Keluargamenuwarga(),
              routes: [
                GoRoute(
                  path: 'profil',
                  name: 'ProfilKeluarga',
                  builder: (context, state) {
                    final keluarga = state.extra as dynamic;
                    return ProfilKeluargaPage(keluarga: keluarga);
                  },
                ),

                // TAMBAH ANGGOTA
                GoRoute(
                  path: 'tambah',
                  name: 'TambahAnggotaKeluarga',
                  builder: (context, state) =>
                      const TambahAnggotaKeluargaPage(),
                ),

                // DAFTAR ANGGOTA
                GoRoute(
                  path: 'anggota',
                  name: 'DaftarAnggotaKeluarga',
                  builder: (context, state) =>
                      const DaftarAnggotaKeluargaPage(),
                  routes: [
                    // DETAIL ANGGOTA
                    GoRoute(
                      path: 'detail',
                      name: 'DetailAnggotaKeluarga',
                      builder: (context, state) {
                        final anggota = state.extra as Anggota;
                        return DetailAnggotaKeluargaPage(anggota: anggota);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          name: 'EditAnggotaKeluarga',
                          builder: (context, state) {
                            final anggota = state.extra as Anggota;
                            return EditAnggotaPage(anggota: anggota);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'tagihan',
                  name: 'DaftarTagihanWarga',
                  builder: (context, state) => const DaftarTagihanWargaScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: 'DetailTagihanWarga',
                      builder: (context, state) {
                        final tagihan = state.extra as WargaTagihanModel;
                        return DetailTagihanWargaScreen(tagihan: tagihan);
                      },
                      routes: [
                        GoRoute(
                          path: 'bayar',
                          name: 'FormPembayaranWarga',
                          builder: (context, state) {
                            final data = state.extra as Map<String, dynamic>;
                            final tagihan = data['tagihan'] as WargaTagihanModel;
                            final channel = data['channel'] as Map<String, String>?;
                            return FormPembayaranScreen(
                              tagihan: tagihan,
                              channel: channel,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/warga/marketplace',
              name: 'WargaMarketplaceMenu',
              builder: (_, __) => const MarketplaceMenuWarga(),
              routes: [
                //belanja
                GoRoute(
                  path: 'explore',
                  name: 'WargaExploreShop',
                  builder: (_, __) => const ShopHomeScreen(),
                ),
                GoRoute(
                  path: 'search',
                  name: 'WargaProductSearch',
                  builder: (_, __) => const ProductSearchScreen(),
                ),
                GoRoute(
                  path: 'detail',
                  name: 'WargaProductDetail',
                  builder: (_, state) {
                    final product = state.extra as ProductModel?;
                    if (product == null) {
                      return const Center(child: Text("Product not found"));
                    }
                    return WargaProductDetailScreen(product: product);
                  },
                ),
                GoRoute(
                  path: 'cart',
                  name: 'WargaCart',
                  builder: (_, __) => const CartScreen(),
                ),
                GoRoute(
                  path: 'checkout',
                  name: 'WargaCheckout',
                  builder: (_, __) => const CheckoutScreen(),
                ),
                GoRoute(
                  path: 'orders',
                  name: 'WargaOrders',
                  builder: (_, __) => const OrderHistoryScreen(),
                ),
                GoRoute(
                  path: 'my-orders',
                  name: 'MyOrders',
                  builder: (_, __) => const MyOrdersScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: 'BuyerOrderDetail',
                      builder: (_, state) {
                        final extra = state.extra;
                        if (extra == null || extra is! o_model.OrderModel) {
                          return const Center(child: Text("Order Not Found"));
                        }
                        return BuyerOrderDetailScreen(order: extra);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'reviewsproduk/:productId',
                  name: 'WargaProductReviews',
                  builder: (context, state) {
                    final productId = state.pathParameters['productId']!;
                    return ProductReviewScreen(productId: productId);
                  },
                ),
                // TOKO SAYA
                GoRoute(
                  path: '/auth-store',
                  name: 'AuthStoreScreen',
                  builder: (_, __) => const AuthStoreScreen(),
                ),
                GoRoute(
                  path: '/login-store',
                  name: 'WargaStoreLoginScreen',
                  builder: (_, __) => const WargaStoreLoginScreen(),
                ),
                GoRoute(
                  path: '/register-store',
                  name: 'WargaStoreRegister',
                  builder: (_, __) => const WargaStoreRegisterScreen(),
                ),
                GoRoute(
                  path: '/store-pending',
                  name: 'StorePendingValidation',
                  builder: (_, __) => const StorePendingValidationScreen(),
                ),
                GoRoute(
                  path: '/store-pending-deactivation',
                  name: 'StorePendingDeactivation',
                  builder: (_, __) => const StorePendingDeactivationScreen(),
                ),
                GoRoute(
                  path: '/mystore-dashboard',
                  name: 'WargaMarketplaceHome',
                  builder: (_, __) => const MyStoreDashboardScreen(),
                  routes: [
                    GoRoute(
                      path: 'mystore',
                      name: 'WargaMarketplaceStore',
                      builder: (_, __) => const MyStoreDashboardScreen(),
                      routes: [
                        GoRoute(
                          path: 'stock',
                          name: 'WargaMarketplaceStoreStock',
                          builder: (_, __) => const MyStoreStockScreen(),
                        ),
                        GoRoute(
                          path: 'product',
                          name: 'MyStoreProductDetail',
                          builder: (_, state) {
                            final product = state.extra as ProductModel?;
                            if (product == null)
                              return const Center(
                                child: Text("Product Not Found"),
                              );
                            return MyStoreProductDetailScreen(product: product);
                          },

                          routes: [
                            GoRoute(
                              path: 'edit',
                              name: 'MyStoreProductEdit',
                              builder: (_, state) {
                                final product = state.extra as ProductModel?;
                                if (product == null)
                                  return const Center(
                                    child: Text("Invalid data"),
                                  );

                                return MyStoreProductEditScreen(
                                  product: product,
                                );
                              },
                            ),
                          ],
                        ),
                        GoRoute(
                          path: 'add',
                          name: 'MyStoreProductAdd',
                          builder: (_, __) => const MyStoreProductAddScreen(),
                        ),
                        GoRoute(
                          path: 'reviews',
                          name: 'MyStoreReviews',
                          builder: (_, __) => const MyStoreReviewsScreen(),
                        ),
                      ],
                    ),

                    // pesanan
                    GoRoute(
                      path: 'orders',
                      name: 'MyStoreOrders',
                      builder: (_, __) => const Menupesanan(),
                      routes: [
                        GoRoute(
                          path: 'detail',
                          name: 'MyStoreOrderDetail',
                          builder: (_, state) {
                            final extra = state.extra;

                            if (extra == null || extra is! o_model.OrderModel) {
                              return const Center(
                                child: Text("Order Not Found"),
                              );
                            }

                            return MyStoreOrderDetail(order: extra);
                          },
                        ),
                      ],
                    ),
                    // pengaturan
                    GoRoute(
                      path: 'settings',
                      name: 'MyStoreSettings',
                      builder: (context, state) =>
                          const MyStoreSettingsScreen(),
                      routes: [
                        GoRoute(
                          path: 'edit_store_profile',
                          name: 'EditStoreProfile',
                          builder: (context, state) =>
                              const EditStoreProfileScreen(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/warga/kegiatan',
              name: 'WargaKegiatanMenu',
              builder: (_, __) => const WargaMenuKegiatanScreen(),
              routes: [
                GoRoute(
                  path: 'list',
                  name: 'warga_kegiatanList',
                  builder: (_, __) => const DaftarKegiatanWargaScreen(),
                ),
                GoRoute(
                  path: 'detail/:id',
                  name: 'WargaKegiatanDetail',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return DetailKegiatanWargaScreen(kegiatanId: id);
                  },
                ),
                GoRoute(
                  path: 'warga-broadcast',
                  name: 'warga_broadcastList',
                  builder: (_, __) => const DaftarBroadcastWargaScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail/:id',
                      name: 'WargaBroadcastDetail',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return DetailBroadcastWargaScreen(broadcastId: id);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'aspirasi',
                  name: 'warga_aspirasiHome',
                  builder: (_, __) => const WargaDaftarAspirasiScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: 'warga_aspirasiDetail',
                      builder: (context, state) {
                        final extra = state.extra;

                        if (extra == null) {
                          return const Scaffold(
                            body: Center(child: Text('Data tidak ditemukan')),
                          );
                        }
                        late AspirasiModel aspirasi;
                        if (extra is AspirasiModel) {
                          aspirasi = extra;
                        } else if (extra is Map<String, dynamic>) {
                          aspirasi = AspirasiModel.fromJson(jsonEncode(extra));
                        } else {
                          return const Scaffold(
                            body: Center(child: Text('Data tidak valid')),
                          );
                        }
                        return WargaDetailAspirasiScreen(data: aspirasi);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'kiriman-saya',
                  name: 'warga_pesanSaya',
                  builder: (context, state) => const WargaPesanSayaScreen(),
                ),
                GoRoute(
                  path: 'kiriman/detail',
                  name: 'warga_kirimanDetail',
                  builder: (context, state) {
                    final extra = state.extra;
                    if (extra == null) {
                      return const Scaffold(
                        body: Center(child: Text('Data tidak ditemukan')),
                      );
                    }
                    late AspirasiModel data;
                    if (extra is AspirasiModel) {
                      data = extra;
                    } else if (extra is Map<String, dynamic>) {
                      data = AspirasiModel.fromMap(extra);
                    } else if (extra is String) {
                      data = AspirasiModel.fromJson(extra);
                    } else {
                      return const Scaffold(
                        body: Center(child: Text('Format data tidak valid')),
                      );
                    }
                    return WargaDetailKirimanScreen(data: data);
                  },
                ),

                GoRoute(
                  path: 'kiriman/edit',
                  name: 'warga_kirimanEdit',
                  builder: (context, state) {
                    final extra = state.extra;

                    if (extra == null) {
                      return const Scaffold(
                        body: Center(child: Text('Data tidak ditemukan')),
                      );
                    }

                    late AspirasiModel data;

                    if (extra is AspirasiModel) {
                      data = extra;
                    } else if (extra is Map<String, dynamic>) {
                      data = AspirasiModel.fromMap(extra);
                    } else if (extra is String) {
                      data = AspirasiModel.fromJson(extra);
                    } else {
                      return const Scaffold(
                        body: Center(child: Text('Format data tidak valid')),
                      );
                    }

                    return WargaEditKirimanScreen(data: data);
                  },
                ),
                GoRoute(
                  path: 'form',
                  name: 'warga_aspirasiForm',
                  builder: (context, state) =>
                      const WargaTambahAspirasiScreen(),
                ),
                GoRoute(
                  path: 'tentang',
                  name: 'warga_tentangAplikasi',
                  builder: (context, state) => const AboutAppScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/warga/profil',
              name: 'profil_menu_warga',
              builder: (_, __) => const ProfilMenuWarga(),
              routes: [
                GoRoute(
                  path: 'data-diri',
                  name: 'WargaDataDiri',
                  builder: (context, state) => const WargaDataDiriScreen(),
                ),
                GoRoute(
                  path: 'edit-data',
                  builder: (context, state) {
                    final initialData = state.extra as Map<String, dynamic>? ?? {};
                    return WargaEditDataDiriScreen(initialData: initialData);
                  },
                ),
                GoRoute(
                  path: 'pengaturan',
                  name: 'WargaPengaturanAkun',
                  builder: (context, state) => const PengaturanAkunScreen(),
                  routes: [
                    GoRoute(
                      path: 'ganti-password',
                      builder: (context, state) => const GantiKataSandiScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'bantuan', // untuk Pusat Bantuan
                  name: 'PusatBantuan',
                  builder: (context, state) => const PusatBantuanScreen(),
                ),
                GoRoute(
                  path: 'about', // untuk Tentang Aplikasi
                  name: 'AboutApp',
                  builder: (context, state) => const AboutAppScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
