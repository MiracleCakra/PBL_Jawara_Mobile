import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'dart:io';
import 'package:jawara_pintar_kel_5/services/warga_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/anggota_keluarga_model.dart'; 

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

  String _query = '';
  String? _filterGender;
  String? _filterStatus;

  List<Anggota> _allAnggota = [];
  List<Anggota> _newAnggota = []; 
  bool _isLoading = true;
  bool _hasFamily = true; // New state variable

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
    await context.pushNamed('DetailAnggotaKeluarga', extra: anggota);
    _loadData();
  }

  Future<void> _navigateToEdit(Anggota anggota) async {
    await context.pushNamed('EditAnggotaKeluarga', extra: anggota);
    _loadData();
  }

  Future<void> _navigateToTambah() async {
    final result = await context.pushNamed('TambahAnggotaKeluarga');
    if (result != null) {
      _loadData();
    }
  }

  void _showKirimPengajuan() {
    if (_newAnggota.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Belum ada anggota baru yang ditambahkan'),
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
        onSubmit: () {
          setState(() {
            _allAnggota.addAll(_newAnggota);
            _newAnggota.clear();
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pengajuan berhasil dikirim'),
              backgroundColor: Colors.grey.shade800,
            ),
          );
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Gender
                  const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempGender,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    hint: const Text("Semua"),
                    items: ['Pria', 'Wanita']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setModalState(() => tempGender = val),
                  ),
                  const SizedBox(height: 16),

                  // Filter Status
                  const Text('Status Penduduk', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempStatus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    hint: const Text("Semua"),
                    items: ['Aktif', 'Nonaktif']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setModalState(() => tempStatus = val),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempGender = null;
                              tempStatus = null;
                            });
                          },
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E46B4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setState(() {
                              _filterGender = tempGender;
                              _filterStatus = tempStatus;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Terapkan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
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

      floatingActionButton: _newAnggota.isEmpty
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF4E46B4),
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

          if (_newAnggota.isNotEmpty)
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
                              'Kirim Pengajuan (${_newAnggota.length})',
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
  final VoidCallback onSubmit;

  const _KirimPengajuanModal({
    required this.jumlahAnggota,
    required this.onSubmit,
  });

  @override
  State<_KirimPengajuanModal> createState() => _KirimPengajuanModalState();
}

class _KirimPengajuanModalState extends State<_KirimPengajuanModal> {
  String? _fotoKKPath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _fotoKKPath = image.path;
        });
        if (mounted)
          Navigator.pop(context); // Close bottom sheet after selecting
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4E46B4)),
                title: const Text('Kamera'),
                onTap: () => _pickImageFromSource(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF4E46B4),
                ),
                title: const Text('Galeri'),
                onTap: () => _pickImageFromSource(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
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
            onTap: _showImageSourcePicker,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _fotoKKPath == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tap untuk upload foto KK'),
                      ],
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
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
                            onTap: () => setState(() => _fotoKKPath = null),
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
                  onPressed: _fotoKKPath == null ? null : widget.onSubmit,
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

  const _AnggotaCard({required this.anggota, this.onTap});

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
