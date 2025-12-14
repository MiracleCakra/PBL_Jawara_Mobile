import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'dart:io';
import 'package:jawara_pintar_kel_5/utils.dart' show getPrimaryColor;
import 'package:jawara_pintar_kel_5/services/warga_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/anggota_keluarga_model.dart'; 
import 'package:jawara_pintar_kel_5/services/keluarga_service.dart'; // <--- TAMBAHIN INI

class DaftarAnggotaKeluargaPage extends StatefulWidget {
  const DaftarAnggotaKeluargaPage({super.key});

  @override
  State<DaftarAnggotaKeluargaPage> createState() =>
      _DaftarAnggotaKeluargaPageState();
}

class _DaftarAnggotaKeluargaPageState extends State<DaftarAnggotaKeluargaPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final WargaService _wargaService = WargaService();
  final KeluargaService _keluargaService = KeluargaService();

  String _query = '';
  String? _filterGender;
  String? _filterStatus;

  List<Anggota> _allAnggota = [];
  List<Anggota> _newAnggota = []; 
  bool _isLoading = true;
  bool _hasFamily = true; 
  String? _keluargaId;
  String? _currentFotoKk;
  bool _hasPendingChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email != null) {
        final currentUser = await _wargaService.getWargaByEmail(email);
        
        if (currentUser != null && currentUser.keluargaId != null) {
          // Fetch full Keluarga object to get foto_kk
          final keluarga = await _keluargaService.getKeluargaByEmail(email);

          final familyMembers = await _wargaService.getWargaByKeluargaId(currentUser.keluargaId!);
          
          final mappedMembers = familyMembers.map((w) => Anggota(
            nama: w.nama,
            nik: w.id, 
            jenisKelamin: w.gender?.value ?? '-',
            peranKeluarga: (w.anggotaKeluarga != null && w.anggotaKeluarga!.isNotEmpty) 
                ? w.anggotaKeluarga!.first.peran ?? '-' 
                : "Anggota Keluarga",
            status: w.statusPenduduk?.value ?? '-',
          )).toList();

          if (mounted) {
            setState(() {
              _keluargaId = currentUser.keluargaId;
              _currentFotoKk = keluarga?.fotoKk;
              _hasFamily = true;
              _allAnggota = mappedMembers;
              _isLoading = false;
            });
          }
        } else {
           if (mounted) {
            setState(() {
              _hasFamily = false; // User has no family
              _allAnggota = [];
              _isLoading = false;
            });
          }
        }
      } else {
         if (mounted) {
            setState(() {
              _hasFamily = false;
              _allAnggota = [];
              _isLoading = false;
            });
          }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  List<Anggota> get _filtered {
    return _allAnggota.where((a) {
      final matchesQuery =
          _query.isEmpty ||
          a.nama.toLowerCase().contains(_query.toLowerCase()) ||
          a.nik.contains(_query);

      final matchesGender =
          _filterGender == null ||
          _filterGender!.isEmpty ||
          (a.jenisKelamin ?? '').toLowerCase() == _filterGender!.toLowerCase();

      final matchesStatus = 
          _filterStatus == null ||
          _filterStatus!.isEmpty ||
          (a.status ?? '').toLowerCase() == _filterStatus!.toLowerCase();

      return matchesQuery && matchesGender && matchesStatus;
    }).toList();
  }

  Future<void> _navigateToDetail(Anggota anggota) async {
    final result = await context.pushNamed('DetailAnggotaKeluarga', extra: anggota);
    if (result == true) {
      _loadData();
      setState(() {
        _hasPendingChanges = true;
      });
    } else {
      _loadData();
    }
  }

  Future<void> _navigateToEdit(Anggota anggota) async {
    final result = await context.pushNamed('EditAnggotaKeluarga', extra: anggota);
    if (result == true) {
      _loadData(); // Reload to reflect data changes
      setState(() {
        _hasPendingChanges = true; // Trigger bottom bar for KK update
      });
    }
  }

  Future<void> _navigateToTambah() async {
    final result = await context.pushNamed('TambahAnggotaKeluarga');
    if (result != null && result is Map) {
      if (result['newMember'] != null) {
        final Warga w = result['newMember'];
        final newAnggota = Anggota(
          nama: w.nama,
          nik: w.id, 
          jenisKelamin: w.gender?.value ?? '-',
          peranKeluarga: result['role'] ?? "Anggota Keluarga",
          status: w.statusPenduduk?.value ?? '-',
        );
        setState(() {
          _newAnggota.add(newAnggota);
        });
      } else if (result['refresh'] == true) {
        _loadData();
      }
    }
  }

  void _showKirimPengajuan() {
    // Cek validasi dasar
    if (_newAnggota.isEmpty && !_hasPendingChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Belum ada perubahan untuk diajukan'),
          backgroundColor: Colors.grey.shade800,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _KirimPengajuanModal(
        jumlahAnggota: _newAnggota.length,
        currentFotoUrl: _currentFotoKk,
        onSubmit: ({File? file, Uint8List? bytes, required String fileName}) async {
          Navigator.pop(context); // 1. Tutup modal dulu

          if (_keluargaId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID Keluarga tidak ditemukan')),
            );
            return;
          }

          // 2. Set Loading State
          setState(() => _isLoading = true);

          try {
            // 3. Proses Upload ke Supabase
            final fileExt = fileName.split('.').last;
            final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_foto_kk.$fileExt';
            
            final imageUrl = await _keluargaService.uploadFotoKk(
              file: file,
              bytes: bytes,
              fileName: uniqueFileName,
              keluargaId: _keluargaId!,
            );

            // 4. Update URL Foto di Database
            await _keluargaService.updateFotoKk(_keluargaId!, imageUrl);

            // 5. Refresh Data dari Server DULU (biar data member masuk ke list utama)
            await _loadData();

            // 6. BARU Reset State Lokal (Hilangkan tombol & kosongkan list temp)
            if (mounted) {
              setState(() {
                _newAnggota.clear();        // Kosongkan list kuning
                _hasPendingChanges = false; // Matikan flag perubahan
                _isLoading = false;         // Matikan loading (jika _loadData belum mematikan)
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Pengajuan berhasil dikirim!'),
                  backgroundColor: Colors.grey.shade800,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            // Error Handling
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal mengirim pengajuan: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _openFilter() {
    String? tempGender = _filterGender;
    String? tempStatus = _filterStatus;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Supaya bisa menyesuaikan tinggi konten
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Bungkus dengan Padding yang menangani keyboard dan ScrollView
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Filter Data',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Filter Gender
                      const Text('Jenis Kelamin',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempGender,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        hint: const Text("Semua"),
                        items: ['Pria', 'Wanita']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) =>
                            setModalState(() => tempGender = val),
                      ),
                      const SizedBox(height: 16),

                      // Filter Status
                      const Text('Status Penduduk',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempStatus,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        hint: const Text("Semua"),
                        items: ['Aktif', 'Nonaktif']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) =>
                            setModalState(() => tempStatus = val),
                      ),

                      const SizedBox(height: 24),

                      // MENGGUNAKAN WIDGET AKSI BARU
                      _buildFilterActions(
                        onReset: () {
                          setModalState(() {
                            tempGender = null;
                            tempStatus = null;
                          });
                        },
                        onApply: () {
                          setState(() {
                            _filterGender = tempGender;
                            _filterStatus = tempStatus;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 20), // Jarak aman tambahan
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildFilterActions({
    required VoidCallback onReset,
    required VoidCallback onApply,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: getPrimaryColor(context), // Menggunakan warna primary
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Terapkan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Daftar Anggota Keluarga'),
      ),

      floatingActionButton: (_newAnggota.isEmpty && !_hasPendingChanges)
          ? FloatingActionButton(
              backgroundColor: getPrimaryColor(context),
              onPressed: _navigateToTambah,
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            )
          : null,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: "Cari Nama Anggota...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4E46B4),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // TOMBOL FILTER
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _openFilter,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.tune, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasFamily 
                  ? const Center(child: Text("Tidak bergabung dalam keluarga apapun"))
                  : _filtered.isEmpty && _newAnggota.isEmpty
                    ? const Center(child: Text("Tidak ada data"))
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 80,
                        ),
                        itemCount: _filtered.length + _newAnggota.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          if (i < _filtered.length) {
                            return _AnggotaCard(
                              anggota: _filtered[i],
                              onTap: () => _navigateToDetail(_filtered[i]),
                              onEdit: () => _navigateToEdit(_filtered[i]), // Pass edit handler
                            );
                          } else {
                            return _AnggotaCard(
                              anggota: _newAnggota[i - _filtered.length],
                              onTap: () {},
                            );
                          }
                        },
                      ),
          ),

          if (_newAnggota.isNotEmpty || _hasPendingChanges)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Button Kirim Pengajuan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showKirimPengajuan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E46B4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF4E46B4).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _hasPendingChanges 
                                  ? 'Update KK & Ajukan' 
                                  : 'Kirim Pengajuan (${_newAnggota.length})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Button Tambah Anggota
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E46B4),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4E46B4).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _navigateToTambah,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _KirimPengajuanModal extends StatefulWidget {
  final int jumlahAnggota;
  final String? currentFotoUrl;
  final Function({File? file, Uint8List? bytes, required String fileName}) onSubmit;

  const _KirimPengajuanModal({
    required this.jumlahAnggota,
    this.currentFotoUrl,
    required this.onSubmit,
  });

  @override
  State<_KirimPengajuanModal> createState() => _KirimPengajuanModalState();
}

class _KirimPengajuanModalState extends State<_KirimPengajuanModal> {
  String? _fotoKKPath;
  Uint8List? _fotoKKBytes;
  String? _fotoKKName;
  
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Important for Web
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;

        setState(() {
          _fotoKKName = file.name;
          if (kIsWeb) {
            _fotoKKBytes = file.bytes;
            _fotoKKPath = null;
          } else {
             if (file.path != null) {
              _fotoKKPath = file.path;
              _fotoKKBytes = null;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  void _handleSubmit() {
    if (_fotoKKPath == null && _fotoKKBytes == null) return;
    
    widget.onSubmit(
      file: _fotoKKPath != null ? File(_fotoKKPath!) : null,
      bytes: _fotoKKBytes,
      fileName: _fotoKKName ?? 'foto_kk.jpg',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Kirim Pengajuan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Anda akan mengajukan ${widget.jumlahAnggota} anggota keluarga baru.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Text(
            'Upload Foto Kartu Keluarga',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: (_fotoKKPath == null && _fotoKKBytes == null)
                  ? (widget.currentFotoUrl != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.currentFotoUrl!,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.broken_image, size: 40)),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white, size: 30),
                                    SizedBox(height: 4),
                                    Text('Ganti Foto', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap untuk upload foto KK'),
                          ],
                        ))
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.memory(
                                  _fotoKKBytes!,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_fotoKKPath!),
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: InkWell(
                            onTap: () => setState(() {
                              _fotoKKPath = null;
                              _fotoKKBytes = null;
                              _fotoKKName = null;
                            }),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_fotoKKPath == null && _fotoKKBytes == null) ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E46B4),
                    disabledBackgroundColor: const Color(
                      0xFF4E46B4,
                    ).withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF4E46B4).withOpacity(0.3),
                  ),
                  child: const Text(
                    'Ajukan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AnggotaCard extends StatelessWidget {
  final Anggota anggota;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const _AnggotaCard({required this.anggota, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isMale = (anggota.jenisKelamin?.toLowerCase() ?? "") == "pria";
    final status = (anggota.status?.toLowerCase() ?? "");

    // --- FIXED STATUS CHIP ---
    Color statusColor;
    Color statusTextColor = Colors.white;

    if (status == "aktif") {
      statusColor = const Color(0xFF4E46B4); // Ungu
    } else if (status == "pengajuan") {
      statusColor = const Color(0xFFFBC02D); // Kuning
      statusTextColor = Colors.white;
    } else {
      statusColor = Colors.grey.shade400; // Nonaktif
      statusTextColor = Colors.black87;
    }

    final genderBgColor = isMale ? Colors.blue.shade50 : Colors.pink.shade50;
    final genderTextColor = isMale
        ? Colors.blue.shade700
        : Colors.pink.shade700;
    final genderIconColor = isMale ? Colors.blue : Colors.pink;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anggota.nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("NIK: ${anggota.nik}"),
                  Text("Peran: ${anggota.peranKeluarga ?? '-'}"),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.flag, size: 16, color: statusTextColor),
                            const SizedBox(width: 4),
                            Text(
                              anggota.status ?? '',
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // GENDER CHIP
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: genderBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isMale ? Icons.male : Icons.female,
                              size: 16,
                              color: genderIconColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              anggota.jenisKelamin ?? '',
                              style: TextStyle(
                                color: genderTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
