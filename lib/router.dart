import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga_model.dart' as k_model;
import 'package:jawara_pintar_kel_5/models/warga_model.dart' as warga_model;

import 'package:jawara_pintar_kel_5/screens/auth/login.dart';
import 'package:jawara_pintar_kel_5/screens/auth/register.dart';

// =========================== ADMIN ===========================
import 'package:jawara_pintar_kel_5/screens/admin/dashboard/dashboard.dart';
import 'package:jawara_pintar_kel_5/screens/admin/layout.dart';

// --- Keluarga ---
import 'package:jawara_pintar_kel_5/screens/admin/keluarga/tambah_keluarga_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keluarga/edit_keluarga_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keluarga/keluarga_list_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/warga/daftar_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/warga/tambah_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/warga/edit_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/warga/detail_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keluarga/keluarga_menu.dart';
import 'package:jawara_pintar_kel_5/screens/warga/penduduk/daftar_keluarga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keluarga/daftar_mutasi_keluarga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keluarga/tambah_mutasi_keluarga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/keluarga/detail_keluarga.dart';

// --- Marketplace ---
import 'package:jawara_pintar_kel_5/screens/admin/marketplace/menu_marketplace.dart';
import 'package:jawara_pintar_kel_5/screens/admin/marketplace/validasiproduk.dart';
import 'package:jawara_pintar_kel_5/screens/admin/marketplace/detail_validasi_produk.dart';
import 'package:jawara_pintar_kel_5/models/marketplace_model.dart' as marketplace_model;

// --- Aktivitas ---
import 'package:jawara_pintar_kel_5/screens/admin/aktivitas/aktivitas_menu.dart';
import 'package:jawara_pintar_kel_5/screens/admin/aktivitas/logaktivitas_admin.dart';

// --- Pengguna ---
import 'package:jawara_pintar_kel_5/screens/admin/pengguna/pengguna_menu.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pengguna/daftar_pengguna.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pengguna/tambah_pengguna.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pengguna/detail_pengguna.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pengguna/edit_pengguna.dart';


// ====== KOMENTAR IMPORT (TIDAK DIHAPUS) ======
/*import 'package:jawara_pintar_kel_5/screens/warga/keuangan/keuangan_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keuangan/laporan_keuangan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keuangan/pengeluaran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/laporan/cetak_laporan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/laporan/semua_pemasukan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/laporan/semua_pengeluaran_screen.dart';

import 'package:jawara_pintar_kel_5/screens/warga/pemasukan/detail_pemasukan_lain_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/pemasukan/kategori_iuran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/pemasukan/pemasukan_lain_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/pemasukan/pemasukan_lain_tambah_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/pemasukan/pemasukan_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/pemasukan/tagih_iuran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/pemasukan/tagihan_screen.dart';*/

/*import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/daftar_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/daftar_rumah.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/tambah_rumah.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/detail_rumah.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/rumah/edit_rumah.dart';

import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/detail_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/tambah_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/warga/edit_warga.dart';

import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/detail_penerimaan_warga.dart';

import 'package:jawara_pintar_kel_5/screens/admin/penduduk/keluarga/daftar_keluarga.dart';

import 'package:jawara_pintar_kel_5/screens/warga/lainnya/lainnya_menu_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/lainnya/edit_profile_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pengguna/manajemen_pengguna_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/lainnya/manajemen_channel_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/lainnya/channel_transfer/tambah_channel.dart';
import 'package:jawara_pintar_kel_5/screens/warga/lainnya/channel_transfer/detail_channel.dart';
import 'package:jawara_pintar_kel_5/screens/warga/lainnya/channel_transfer/edit_channel.dart';

import 'package:jawara_pintar_kel_5/screens/warga/pengeluaran/daftar_pengeluaran_screen.dart';
import 'package:jawara_pintar_kel_5/screens/warga/pengeluaran/tambah_pengeluaran_screen.dart';*/

/*import 'package:jawara_pintar_kel_5/screens/admin/kegiatanMenu/...';*/
// =============================================================


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

    // ================= AUTH =================
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

    // ================= ROOT SHELL =================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdminLayout(navigationShell: navigationShell),

      branches: [

        // ========== Dashboard ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/dashboard',
              name: 'admin_dashboard',
              builder: (context, state) => AdminDashboard(),
            ),
          ],
        ),

        // ========== Keluarga ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/keluarga',
              name: 'keluargaMenuPage',
              builder: (context, state) => const KeluargaMenuPage(),
                        routes: [
                          GoRoute(
                            path: 'list-keluarga',
                            name: 'listKeluarga',
                            builder: (context, state) => const KeluargaListScreen(),
                            routes: [
                              GoRoute(
                                path: 'tambah',
                                name: 'tambahKeluarga',
                                builder: (context, state) => const TambahKeluargaScreen(),
                              ),
                              GoRoute(
                                path: 'edit',
                                name: 'editKeluarga',
                                builder: (context, state) {
                                  final keluarga = state.extra as k_model.Keluarga;
                                  return EditKeluargaScreen(keluarga: keluarga);
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                              path: 'list-warga',
                              name: 'listWarga',
                              builder: (context, state) => const DaftarWargaPage(),
                              routes: [
                                GoRoute(
                                  path: 'tambah',
                                  name: 'tambahWarga',
                                  builder: (context, state) => const TambahWargaPage(),
                                ),
                                GoRoute(
                                  path: 'edit',
                                  name: 'editWarga',
                                  builder: (context, state) {
                                    final warga = state.extra as warga_model.Warga;
                                    return EditWargaPage(warga: warga);
                                  },
                                ),
                                GoRoute(
                                  path: 'detail',
                                  name: 'detailWarga',
                                  builder: (context, state) {
                                    final warga = state.extra as warga_model.Warga;
                                    return DetailWargaPage(warga: warga);
                                  },
                                ),
                              ]),
                          GoRoute(
                            path: 'daftar_keluarga',
                            name: 'wargaList',
                            builder: (context, state) => const DaftarKeluargaPage(),
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
                            path: 'daftar',
                            name: 'mutasiKeluargaList',
                            builder: (context, state) => const DaftarMutasiKeluargaPage(),
                          ),
                          GoRoute(
                            path: 'tambah',
                            name: 'mutasiKeluargaAdd',
                            builder: (context, state) => const TambahMutasiKeluargaPage(),
                          ),
                        ],            ),
          ],
        ),

        // ========== Marketplace ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/marketplace',
              name: 'marketplaceMenu',
              builder: (context, state) => const MarketplaceMenuScreen(),
              routes: [
                GoRoute(
                  path: 'validasiproduk',
                  name: 'validasiProdukList',
                  builder: (context, state) =>
                      const ValidasiProdukBaruScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: 'validasiProdukDetail',
                      builder: (context, state) {
                        final product =
                            state.extra as marketplace_model.ActiveProductItem?;
                        if (product == null) {
                          return const ValidasiProdukBaruScreen();
                        }
                        return DetailValidasiProdukScreen(product: product);
                      },
                    ),
                    GoRoute(
                      path: 'detailproduk',
                      name: 'produkAktifDetail',
                      builder: (context, state) {
                        final product =
                            state.extra as marketplace_model.ActiveProductItem?;
                        if (product == null) {
                          return const MarketplaceMenuScreen();
                        }
                        return DetailValidasiProdukScreen(product: product);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ========== Aktivitas ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/aktivitas',
              name: 'aktivitasMenu',
              builder: (context, state) => const AktivitasMenuScreen(),
              routes: [
                GoRoute(
                  path: 'logaktivitas',
                  name: 'logAktivitas',
                  builder: (context, state) =>
                      const LogAktivitasScreenAdmin(),
                ),
              ],
            ),
          ],
        ),

        // ========== Pengguna ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/pengguna',
              name: 'penggunaMenu',
              builder: (context, state) =>
                  const ManajemenPenggunaMenuScreen(),
              routes: [
                GoRoute(
                  path: 'daftar',
                  name: 'daftarPengguna',
                  builder: (context, state) =>
                      const DaftarPenggunaScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: 'penggunaDetail',
                      builder: (context, state) {
                        final userdata =
                            state.extra as Map<String, String>?;
                        if (userdata == null) {
                          return const DaftarPenggunaScreen();
                        }
                        return DetailPenggunaScreen(userData: userdata);
                      },
                    ),
                    GoRoute(
                      path: 'edit',
                      name: 'penggunaEdit',
                      builder: (context, state) {
                        final userdata =
                            state.extra as Map<String, String>?;
                        if (userdata == null) {
                          return const DaftarPenggunaScreen();
                        }
                        return EditPenggunaScreen(userData: userdata);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'tambah',
                  name: 'tambahPengguna',
                  builder: (context, state) =>
                      const TambahPenggunaScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
