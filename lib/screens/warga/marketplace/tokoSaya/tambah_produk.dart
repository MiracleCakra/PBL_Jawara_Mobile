import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/product_service.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyStoreProductAddScreen extends StatefulWidget {
  const MyStoreProductAddScreen({super.key});

  @override
  State<MyStoreProductAddScreen> createState() =>
      _MyStoreProductAddScreenState();
}

class _MyStoreProductAddScreenState extends State<MyStoreProductAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  File? _imageFile;
  String? _predictedCategory;
  bool _isProcessingCV = false;

  // Grade Produk
  String _selectedGrade = 'Grade A';
  final List<String> _grades = ['Grade A', 'Grade B', 'Grade C'];

  // Satuan Produk
  final List<String> _availableUnits = ['kg', 'ikat', 'pcs', 'karung'];
  String _selectedUnit = 'kg'; // default

  static const Color primaryColor = Color(0xFF6A5AE0);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _imageFile = file;
        _isProcessingCV = true;
        _predictedCategory = null;
      });
      _runImageClassification(file);
    }
  }

  Future<void> _runImageClassification(File image) async {
    await Future.delayed(const Duration(seconds: 2));
    final predictions = ['Sayur Grade A', 'Sayur Grade B', 'Sayur Grade C'];
    final randomPrediction =
        predictions[DateTime.now().second % predictions.length];

    if (!mounted) return;

    setState(() {
      _predictedCategory = randomPrediction;
      _isProcessingCV = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CV: Kategori sayur diprediksi sebagai $_predictedCategory',
          ),
        ),
      );
    });
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap unggah foto produk terlebih dahulu!'),
          backgroundColor: Colors.grey.shade800,
        ),
      );
      return;
    }
    if (_isProcessingCV) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tunggu proses klasifikasi gambar selesai...'),
          backgroundColor: Colors.grey.shade800,
        ),
      );
      return;
    }

    final int newPrice = int.tryParse(_priceController.text.trim()) ?? 0;
    final int newStock = int.tryParse(_stockController.text.trim()) ?? 0;

    // Get warga.id (NIK) from warga table using email
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Query warga table to get warga.id (NIK)
    final wargaResponse = await Supabase.instance.client
        .from('warga')
        .select('id')
        .eq('email', authUser!.email!)
        .maybeSingle();

    if (wargaResponse == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data warga tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final userId = wargaResponse['id'] as String;

    // Get store_id from logged in user
    final storeService = StoreService();
    final userStore = await storeService.getStoreByUserId(userId);

    if (userStore == null || userStore.storeId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Anda belum memiliki toko. Silakan daftar toko terlebih dahulu.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mengupload gambar...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    // Upload image to Supabase Storage first
    String? imageUrl;
    try {
      final productService = ProductService();
      imageUrl = await productService.uploadProductImage(
        _imageFile!,
        userStore.storeId!,
      );

      if (imageUrl == null) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gagal mengupload gambar!\n\n'
                'Pastikan:\n'
                '1. Bucket "products" sudah dibuat di Supabase Storage\n'
                '2. Storage Policies sudah diatur (INSERT & SELECT)\n'
                '3. Bucket berstatus Public\n\n'
                'Lihat file QUICK_SETUP_STORAGE.md untuk panduan.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 8),
            ),
          );
        }
        return;
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        String errorMessage = 'Gagal mengupload gambar: $e';

        if (e.toString().contains('404')) {
          errorMessage =
              '❌ Bucket "products" tidak ditemukan!\n\n'
              'Solusi: Buat bucket di Supabase Storage.\n'
              'Lihat QUICK_SETUP_STORAGE.md';
        } else if (e.toString().contains('401') ||
            e.toString().contains('403')) {
          errorMessage =
              '❌ Permission Denied!\n\n'
              'Solusi: Setup Storage Policies di Supabase.\n'
              'Lihat QUICK_SETUP_STORAGE.md';
        } else if (e.toString().contains('409')) {
          errorMessage = '❌ File sudah ada!\n\nCoba lagi.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
      return;
    }

    final newProduct = ProductModel(
      nama: _nameController.text.trim(),
      deskripsi: _descController.text.trim(),
      harga: newPrice.toDouble(),
      stok: newStock,
      satuan: _selectedUnit,
      grade: _selectedGrade,
      gambar: imageUrl, // Use uploaded image URL
      storeId: userStore.storeId,
    );

    // Save to Supabase via ProductProvider
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final savedProduct = await productProvider.createProduct(newProduct);

    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    if (savedProduct != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan ke database!'),
          backgroundColor: Colors.green,
        ),
      );
      context.goNamed('WargaMarketplaceStoreStock');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menambahkan produk: ${productProvider.errorMessage}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Produk Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              if (_isProcessingCV)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Menganalisis gambar...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              if (_predictedCategory != null && !_isProcessingCV)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: Text(
                    'Kategori Prediksi CV: $_predictedCategory',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              const _InputLabel("Nama Produk"),
              _ThemedTextFormField(
                controller: _nameController,
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),

              const _InputLabel("Deskripsi Produk"),
              _ThemedTextFormField(
                controller: _descController,
                maxLines: 3,
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),

              const _InputLabel("Harga"),
              _ThemedTextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: _validatePrice,
              ),
              const SizedBox(height: 12),

              // Stok & Satuan
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _InputLabel("Stok"),
                        _ThemedTextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          validator: _validateStock,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _InputLabel("Satuan"),
                        _ThemedDropdownFormField<String>(
                          value: _selectedUnit,
                          items: _availableUnits
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedUnit = val);
                          },
                          validator: _validateRequired,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const _InputLabel("Grade Kualitas"),
              _ThemedDropdownFormField<String>(
                value: _selectedGrade,
                items: _grades
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGrade = val);
                },
                validator: _validateRequired,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveProduct,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tambah Produk',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InputLabel("Foto Produk"),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(
                          Icons.photo_library,
                          color: primaryColor,
                        ),
                        title: const Text('Pilih dari Galeri'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.camera_alt,
                          color: primaryColor,
                        ),
                        title: const Text('Ambil Foto'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _imageFile == null ? Colors.grey.shade300 : primaryColor,
                width: _imageFile == null ? 1.5 : 2.5,
              ),
            ),
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih/Ambil Foto Produk',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Kolom ini tidak boleh kosong';
    return null;
  }

  String? _validatePrice(String? value) {
    if (_validateRequired(value) != null) return 'Harga tidak boleh kosong';
    if (int.tryParse(value!) == null || int.parse(value) <= 0)
      return 'Masukkan harga yang valid (angka > 0)';
    return null;
  }

  String? _validateStock(String? value) {
    if (_validateRequired(value) != null) return 'Stok tidak boleh kosong';
    if (int.tryParse(value!) == null || int.parse(value) < 0)
      return 'Masukkan stok yang valid (angka >= 0)';
    return null;
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _ThemedTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;

  const _ThemedTextFormField({
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  static const Color primaryColor = _MyStoreProductAddScreenState.primaryColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _ThemedDropdownFormField<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const _ThemedDropdownFormField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  static const Color primaryColor = _MyStoreProductAddScreenState.primaryColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      iconEnabledColor: primaryColor,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
