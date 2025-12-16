<div align="center">
  
# 📱 SapaWarga

### Sistem Informasi Manajemen RT/RW Digital

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![Firebase](https://img.shields.io/badge/Firebase-Core-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Academic-blue.svg)]()

_Aplikasi mobile berbasis Flutter untuk digitalisasi pengelolaan RT/RW dengan fitur Computer Vision untuk deteksi kesegaran sayuran_

[Fitur](#-fitur-utama) • [Teknologi](#-teknologi-stack) • [Instalasi](#-instalasi) • [Tim](#-tim-pengembang)

</div>

---

## 📖 Tentang Proyek

**SapaWarga** adalah aplikasi mobile cross-platform yang dikembangkan sebagai solusi digitalisasi pengelolaan data dan administrasi tingkat RT/RW. Aplikasi ini merupakan versi mobile dari sistem informasi Jawara berbasis web, dengan pengembangan lebih lanjut untuk meningkatkan aksesibilitas dan kemudahan penggunaan.

### 🎯 Latar Belakang

Pengelolaan RT/RW secara konvensional seringkali menghadapi kendala dalam hal:

- Pencatatan data warga yang tidak terstruktur
- Pengelolaan keuangan yang kurang transparan
- Komunikasi yang tidak efisien antara pengurus dan warga
- Kesulitan akses informasi bagi warga

SapaWarga hadir untuk mengatasi permasalahan tersebut dengan menyediakan platform digital yang dapat diakses kapan saja dan di mana saja.

### ✨ Keunggulan

- 📱 **Multi-Platform**: Support Android, iOS.
- 🔐 **Secure Authentication**: Sistem autentikasi aman dengan Supabase Auth
- 🥦 **Computer Vision**: Deteksi kesegaran sayur otomatis menggunakan LightGBM dan U-2-Net
- 📊 **Real-time Data**: Sinkronisasi data real-time dengan Supabase PostgreSQL
- 🎨 **Modern UI**: Desain intuitif menggunakan Moon Design System
- 📈 **Analytics**: Visualisasi data dengan grafik interaktif (FL Chart)
- 📄 **PDF Generation**: Cetak laporan keuangan dalam format PDF
- 🛒 **Marketplace**: Platform UMKM warga dengan sistem review dan rating

---

## 🎯 Fitur Utama

### 👤 Manajemen Pengguna (Role-Based Access)

- **6 Role Pengguna**: Admin, Ketua RT, Ketua RW, Bendahara, Sekretaris, Warga
- Autentikasi dan authorization berbasis role
- Manajemen profil dan data pribadi
- Reset password dan keamanan akun

### 👨‍👩‍👧‍👦 Manajemen Penduduk & Keluarga

- Daftar warga per RT/RW dengan pencarian dan filter
- Data keluarga dan anggota keluarga
- Manajemen kartu keluarga (KK)
- Statistik demografi warga
- Detail informasi warga lengkap

### 💰 Manajemen Keuangan

- **Pemasukan**:
  - Iuran warga (bulanan/tahunan)
  - Pemasukan lain-lain dengan kategori
  - Tracking status pembayaran per warga
  - Upload bukti pembayaran
- **Pengeluaran**:
  - Pencatatan pengeluaran dengan bukti
  - Kategorisasi pengeluaran
  - Validasi pengeluaran oleh bendahara
- **Laporan Keuangan**:
  - Laporan real-time per bulan/tahun
  - Visualisasi grafik pemasukan/pengeluaran (Bar Chart)
  - Filter berdasarkan periode waktu
  - Export laporan ke PDF
  - Dashboard keuangan dengan ringkasan saldo
  - Transparansi keuangan untuk semua warga

### 📢 Kegiatan & Komunikasi

- **Broadcast**: Pengumuman ke seluruh warga RT/RW
- **Kegiatan**: Manajemen event dan kegiatan RT/RW dengan foto dokumentasi
- **Aspirasi Warga**: Sistem pengaduan dan saran dari warga
- **Log Aktivitas**: Tracking aktivitas pengguna dalam sistem
- **Notifikasi**: Informasi kegiatan dan pengumuman penting

### 🛒 Marketplace UMKM Warga

- **Toko Online Warga**:
  - Registrasi toko dengan validasi admin
  - Manajemen produk (CRUD)
  - Upload foto produk multiple
  - **Computer Vision**: Deteksi kesegaran sayur otomatis menggunakan AI
    - Model: LightGBM Classifier
    - Segmentasi: U-2-Net (ONNX)
    - Features: HOG, LBP, Color Histogram, Texture (GLCM)
    - API: FastAPI hosted on HuggingFace Spaces
  - Status toko: pending, approved, rejected, deactivated
- **Shopping**:
  - Browse produk dari warga dengan filter dan pencarian
  - Keranjang belanja dengan update quantity real-time
  - Sistem order dan checkout
  - Rating dan review produk (bintang 1-5)
  - History pembelian
- **Manajemen Toko**:
  - Dashboard penjualan untuk pemilik toko
  - Manajemen pesanan (pending, processing, completed, cancelled)
  - Validasi toko dan produk oleh admin
  - Tracking status pesanan
  - Statistik penjualan

### 📊 Dashboard & Reporting

- Dashboard berbeda untuk setiap role (Admin, RT, RW, Bendahara, Sekretaris, Warga)
- Statistik dan visualisasi data real-time
- Grafik interaktif menggunakan FL Chart (Bar Chart, Pie Chart)
- Export laporan keuangan ke PDF dengan format profesional
- Widget cards untuk ringkasan data penting
- Filter dan pencarian data yang fleksibel

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi dengan Supabase & Firebase init
├── router.dart               # Konfigurasi routing (GoRouter)
├── firebase_options.dart     # Firebase configuration (auto-generated)
├── utils.dart                # Helper functions & utilities
├── constants/                # Konstanta (colors, strings, endpoints)
├── models/                   # Data models
│   ├── keluarga/            # Models warga, keluarga, KK
│   ├── keuangan/            # Models laporan keuangan, transaksi
│   ├── kegiatan/            # Models kegiatan, broadcast, aspirasi
│   ├── log/                 # Models activity log
│   └── marketplace/         # Models produk, toko, order, cart, review
├── providers/               # State management (Provider pattern)
│   ├── product_provider.dart
│   └── marketplace/         # Cart, Store, Order, Review providers
├── services/                # API services & business logic
│   ├── warga_service.dart
│   ├── keluarga_service.dart
│   ├── kegiatan_service.dart
│   ├── broadcast_service.dart
│   ├── aspirasi_service.dart
│   ├── pengguna_service.dart
│   ├── activity_log_service.dart
│   ├── channel_transfer_service.dart
│   └── marketplace/         # Marketplace services
│       ├── product_service.dart
│       ├── store_service.dart
│       ├── cart_service.dart
│       ├── order_service.dart
│       ├── review_service.dart
│       ├── store_verification_helper.dart
│       └── vegetable_detection_service.dart
├── screens/                 # UI Screens by role
│   ├── auth/               # Login, Register screens
│   ├── admin/              # Admin screens (full access)
│   ├── rt/                 # Ketua RT screens
│   ├── rw/                 # Ketua RW screens
│   ├── bendahara/          # Bendahara screens (finance focus)
│   ├── sekretaris/         # Sekretaris screens
│   └── warga/              # Warga screens (limited access)
│       ├── dashboard/      # Dashboard warga
│       ├── kegiatan/       # Kegiatan & broadcast
│       ├── keluarga/       # Data keluarga
│       ├── marketplace/    # Shopping, cart, orders
│       └── profil/         # Profile management
└── widget/                  # Reusable widgets & components

PCVK/                        # Computer Vision API (Python FastAPI)
├── main.py                  # FastAPI application
├── models/                  # Pre-trained ML models (LightGBM, U-2-Net)
│   ├── lgbm_model.pkl      # LightGBM classifier
│   └── u2netp.onnx         # U-2-Net segmentation model
├── requirements.txt         # Python dependencies
├── Dockerfile              # Container configuration
└── test/                   # API testing scripts

integration_test/            # Integration tests (E2E)
├── login_test.dart
├── register_test.dart
├── daftar_warga_test.dart
└── end_to_end/             # Full flow tests

test/                        # Unit & Widget tests
├── unit/                   # Unit tests
├── api/                    # API service tests
├── fixtures/               # Test fixtures & mock data
├── pytest/                 # Python API tests
└── load/                   # Load testing scripts
```

## 👥 Tim Pengembang

| Avatar | Nama                        | NIM        | Role                | Kontribusi                                                                          |
| :----: | --------------------------- | ---------- | ------------------- | ----------------------------------------------------------------------------------- |
|   👨‍💻   | **Afrizal Qurratul Faizin** | 2341720083 | Backend Developer   | Backend logic, E2E Testing                                                          |
|   👨‍💻   | **Cakra Wangsa M.A.W**      | 2341720032 | Fullstack Developer | Full-stack development, ML integration, Marketplace, Computer Vision                |
|   👨‍💻   | **Sirfaratih**              | 2341720072 | Frontend Developer  | UI/UX design, Frontend implementation, Widget development                           |
|   👨‍💻   | **Tionusa Catur Pamungkas** | 2341720093 | Backend Developer   | Backend logic, Authentication & Authorization, Integration testing, Database design |

---

## 🎓 Informasi Akademik

**Institusi**: Politeknik Negeri Malang  
**Program Studi**: D4 Teknik Informatika  
**Mata Kuliah**: Project Based Learning (PBL) - Semester 5  
**Tahun Ajaran**: 2024/2025 Ganjil  
**Kelompok**: 2

---

## 📄 Lisensi

Project ini dibuat untuk keperluan akademik dan pembelajaran. Tidak untuk dipublikasikan secara komersial tanpa izin.

---

## 🙏 Acknowledgments

- Politeknik Negeri Malang - D4 Teknik Informatika
- [Supabase](https://supabase.com) untuk Backend as a Service
- [Firebase](https://firebase.google.com) untuk platform development
- [Flutter Team](https://flutter.dev) & Flutter Community
- [Moon Design System](https://moon-design-system.vercel.app/)
- [HuggingFace](https://huggingface.co) untuk hosting ML model Computer Vision
- Semua open-source contributors yang library-nya digunakan dalam project ini

---

<div align="center">

**Made with ❤️ by Kelompok 2 - PBL Semester 5**

⭐ Star repository ini jika bermanfaat!

</div>
