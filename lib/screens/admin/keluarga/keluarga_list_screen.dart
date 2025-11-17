import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga_model.dart' as k_model;
import 'package:jawara_pintar_kel_5/services/keluarga_service.dart';

class KeluargaListScreen extends StatefulWidget {
  const KeluargaListScreen({super.key});

  @override
  State<KeluargaListScreen> createState() => _KeluargaListScreenState();
}

class _KeluargaListScreenState extends State<KeluargaListScreen> {
  final KeluargaService _keluargaService = KeluargaService();
  late Future<List<k_model.Keluarga>> _keluarga;
  List<k_model.Keluarga> _allKeluarga = [];
  List<k_model.Keluarga> _filteredKeluarga = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _keluarga = _keluargaService.getAllKeluarga();
    _keluarga.then((value) {
      setState(() {
        _allKeluarga = value;
        _filteredKeluarga = value;
      });
    });
    _searchController.addListener(_filterKeluarga);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterKeluarga() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredKeluarga = _allKeluarga.where((keluarga) {
        return keluarga.namaKeluarga.toLowerCase().contains(query) ||
            (keluarga.kepalaKeluarga?.nama.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _refreshKeluargaList() {
    setState(() {
      _keluarga = _keluargaService.getAllKeluarga();
      _keluarga.then((value) {
        setState(() {
          _allKeluarga = value;
          _filteredKeluarga = value;
          _searchController.clear();
        });
      });
    });
  }

  Future<void> _deleteKeluarga(String id) async {
    try {
      await _keluargaService.deleteKeluarga(id);
      _refreshKeluargaList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluarga berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus keluarga: $e')),
      );
    }
  }

  void _showDeleteConfirmation(k_model.Keluarga keluarga) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Keluarga'),
          content: Text(
              'Apakah Anda yakin ingin menghapus keluarga "${keluarga.namaKeluarga}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteKeluarga(keluarga.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Data Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama keluarga atau kepala keluarga...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<k_model.Keluarga>>(
                future: _keluarga,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (_filteredKeluarga.isEmpty) {
                    return const Center(child: Text('Tidak ada data keluarga.'));
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredKeluarga.length,
                      itemBuilder: (context, index) {
                        final keluarga = _filteredKeluarga[index];
                        return _KeluargaCard(
                          keluarga: keluarga,
                          onEdit: () async {
                            final result = await context.pushNamed('editKeluarga', extra: keluarga);
                            if (result == true) {
                              _refreshKeluargaList();
                            }
                          },
                          onDelete: () {
                            _showDeleteConfirmation(keluarga);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.pushNamed('tambahKeluarga');
          if (result == true) {
            _refreshKeluargaList();
          }
        },
        backgroundColor: const Color(0xFF4E46B4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _KeluargaCard extends StatelessWidget {
  final k_model.Keluarga keluarga;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KeluargaCard({
    required this.keluarga,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        keluarga.namaKeluarga,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kepala Keluarga: ${keluarga.kepalaKeluarga?.nama ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Hapus'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
