import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/product_service.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/vegetable_detection_service.dart';
import 'package:jawara_pintar_kel_5/widget/marketplace/custom_dialog.dart';
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
  double? _confidence;
  Map<String, dynamic>? _detectionDetails;
  bool _isProcessingCV = false;
  bool _isUploading = false; // Add this flag for upload state

  final VegetableDetectionService _detectionService =
      VegetableDetectionService();

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
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 100, // Jangan compress, kirim kualitas penuh
      maxWidth: null, // Jangan resize lebar
      maxHeight: null, // Jangan resize tinggi
      requestFullMetadata: false, // Hindari EXIF orientation issues
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // DEBUG: Print file info
      print('📸 Image picked:');
      print('Path: ${file.path}');
      print('Size: ${await file.length()} bytes');

      setState(() {
        _imageFile = file;
        _isProcessingCV = true;
        _predictedCategory = null;
      });
      _runImageClassification(file);
    }
  }

  Future<void> _runImageClassification(File image) async {
    try {
      // Call API deteksi sayur
      final result = await _detectionService.detectVegetableFreshness(image);

      if (!mounted) return;

      if (result['success'] == true) {
        final prediction =
            result['prediction'] as String; // "Segar", "Layu", "Busuk"
        final confidence = result['confidence'] as double;
        final details = result['details'] as Map<String, dynamic>;

        // Map prediction to grade
        final grade = _detectionService.mapPredictionToGrade(prediction);

        setState(() {
          _predictedCategory = prediction;
          _confidence = confidence;
          _detectionDetails = details;
          _selectedGrade = grade; // Auto set grade based on detection
          _isProcessingCV = false;
        });

        // Show success message
        final style = VegetableDetectionService.getPredictionStyle(prediction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(
                    '${style['icon']} ',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          style['message'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Confidence: ${confidence.toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: style['color'],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Handle error
        setState(() {
          _isProcessingCV = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal mendeteksi: ${result['error']}\n\n'
                'Pastikan server PCVK berjalan di:\n'
                'http://localhost:8000',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessingCV = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e\n\n'
            'Pastikan server PCVK berjalan!',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      CustomSnackbar.show(
        context: context,
        message: 'Harap unggah foto produk terlebih dahulu!',
        type: DialogType.warning,
      );
      return;
    }
    if (_isProcessingCV) {
      CustomSnackbar.show(
        context: context,
        message: 'Tunggu proses klasifikasi gambar selesai...',
        type: DialogType.info,
      );
      return;
    }

    final int newPrice = int.tryParse(_priceController.text.trim()) ?? 0;
    final int newStock = int.tryParse(_stockController.text.trim()) ?? 0;

    // Get warga.id (NIK) from warga table using email
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser?.email == null) {
      CustomSnackbar.show(
        context: context,
        message: 'Silakan login terlebih dahulu',
        type: DialogType.error,
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
        CustomSnackbar.show(
          context: context,
          message: 'Data warga tidak ditemukan',
          type: DialogType.error,
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
        CustomSnackbar.show(
          context: context,
          message:
              'Anda belum memiliki toko. Silakan daftar toko terlebih dahulu.',
          type: DialogType.warning,
          duration: const Duration(seconds: 4),
        );
      }
      return;
    }

    // Set uploading state
    setState(() {
      _isUploading = true;
    });

    print('DEBUG: Start uploading, _isUploading = $_isUploading');

    // Upload image to Supabase Storage first
    String? imageUrl;
    try {
      final productService = ProductService();
      imageUrl = await productService.uploadProductImage(
        _imageFile!,
        userStore.storeId!,
      );

      if (imageUrl == null) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          CustomDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Upload Gagal',
            message:
                'Gagal mengupload gambar!\n\nPastikan:\n'
                '1. Bucket "products" sudah dibuat di Supabase Storage\n'
                '2. Storage Policies sudah diatur (INSERT & SELECT)\n'
                '3. Bucket berstatus Public',
            buttonText: 'Mengerti',
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }

      if (mounted) {
        String errorTitle = 'Upload Error';
        String errorMessage = 'Gagal mengupload gambar: $e';

        if (e.toString().contains('404')) {
          errorTitle = 'Bucket Tidak Ditemukan';
          errorMessage =
              'Bucket "products" tidak ditemukan!\n\n'
              'Solusi: Buat bucket di Supabase Storage.\n'
              'Lihat QUICK_SETUP_STORAGE.md';
        } else if (e.toString().contains('401') ||
            e.toString().contains('403')) {
          errorTitle = 'Permission Denied';
          errorMessage =
              'Tidak ada izin untuk mengupload!\n\n'
              'Solusi: Setup Storage Policies di Supabase.\n'
              'Lihat QUICK_SETUP_STORAGE.md';
        } else if (e.toString().contains('409')) {
          errorTitle = 'File Sudah Ada';
          errorMessage =
              'File dengan nama ini sudah ada!\n\nCoba lagi dengan file lain.';
        }

        CustomDialog.show(
          context: context,
          type: DialogType.error,
          title: errorTitle,
          message: errorMessage,
          buttonText: 'Tutup',
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

    try {
      final savedProduct = await productProvider.createProduct(newProduct);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        print('DEBUG: Done saving, _isUploading = $_isUploading');
      }

      if (savedProduct != null) {
        if (mounted) {
          CustomDialog.show(
            context: context,
            type: DialogType.success,
            title: 'Berhasil!',
            message: 'Produk berhasil ditambahkan ke toko Anda!',
            buttonText: 'OK',
            onConfirm: () {
              Navigator.of(context).pop('added');
            },
          );
        }
      } else {
        if (mounted) {
          CustomDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Gagal Menyimpan',
            message:
                'Gagal menambahkan produk: ${productProvider.errorMessage ?? "Terjadi kesalahan"}',
            buttonText: 'Coba Lagi',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        CustomDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Terjadi Kesalahan',
          message: 'Error: $e',
          buttonText: 'Tutup',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                      onPressed: _isUploading ? null : _saveProduct,
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
        ),
        // Loading overlay when uploading
        if (_isUploading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Menyimpan produk...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InputLabel("Foto Produk"),
        // Warning untuk kualitas gambar
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gunakan foto kamera langsung atau gambar asli berkualitas tinggi. Hindari screenshot atau gambar yang di-download ulang.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
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
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit
                              .contain, // Tampilkan gambar penuh tanpa crop
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      if (_isProcessingCV)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Mendeteksi kesegaran...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        // Detection Result Display
        if (_predictedCategory != null && _confidence != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VegetableDetectionService.getPredictionStyle(
                _predictedCategory!,
              )['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: VegetableDetectionService.getPredictionStyle(
                  _predictedCategory!,
                )['color'],
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      VegetableDetectionService.getPredictionStyle(
                        _predictedCategory!,
                      )['icon'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Deteksi: $_predictedCategory',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  VegetableDetectionService.getPredictionStyle(
                                    _predictedCategory!,
                                  )['color'],
                            ),
                          ),
                          Text(
                            'Confidence: ${_confidence!.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_detectionDetails != null) ...[
                  const Divider(height: 16),
                  const Text(
                    'Detail Probabilitas:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  _buildProbabilityBar(
                    'Segar',
                    _detectionDetails!['segar_prob'],
                    Colors.green,
                  ),
                  _buildProbabilityBar(
                    'Layu',
                    _detectionDetails!['layu_prob'],
                    Colors.orange,
                  ),
                  _buildProbabilityBar(
                    'Busuk',
                    _detectionDetails!['busuk_prob'],
                    Colors.red,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProbabilityBar(String label, double probability, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: probability / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${probability.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
