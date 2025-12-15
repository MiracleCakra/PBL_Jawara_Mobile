import 'dart:io';

import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/services/marketplace/product_service.dart';
import 'package:SapaWarga_kel_2/utils.dart' show formatRupiah, unformatRupiah;
import 'package:SapaWarga_kel_2/widget/marketplace/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class MyStoreProductEditScreen extends StatefulWidget {
  final ProductModel product;

  const MyStoreProductEditScreen({super.key, required this.product});

  @override
  State<MyStoreProductEditScreen> createState() =>
      _MyStoreProductEditScreenState();
}

class _MyStoreProductEditScreenState extends State<MyStoreProductEditScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color rejectedColor = Colors.red;
  static const List<String> availableGrades = ['Grade A', 'Grade B', 'Grade C'];
  static const List<String> availableUnits = ['kg', 'ikat', 'pcs', 'karung'];

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final ProductService _productService = ProductService();

  late String _name;
  late String _description;
  late int _price;
  late int _stock;
  late String _grade;
  late String _unit;

  File? _imageFile;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.product.nama ?? '';
    _description = widget.product.deskripsi ?? '';
    _price = widget.product.harga?.toInt() ?? 0;
    _stock = widget.product.stok ?? 0;
    _grade = widget.product.grade ?? 'Grade A';
    _unit = widget.product.satuan ?? 'kg';
    _currentImageUrl = widget.product.gambar;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? imageUrl = _currentImageUrl; // Use existing image by default

      // Upload new image if selected
      if (_imageFile != null) {
        // Show loading only when uploading image
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Mengupload gambar...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );

        try {
          imageUrl = await _productService.uploadProductImage(
            _imageFile!,
            widget.product.storeId!,
          );

          if (mounted) Navigator.pop(context); // Close loading

          if (imageUrl == null) {
            if (mounted) {
              CustomDialog.show(
                context: context,
                type: DialogType.error,
                title: 'Upload Gagal',
                message:
                    'Gagal mengupload gambar baru!\n\nPastikan:\n'
                    '1. Bucket "products" sudah dibuat\n'
                    '2. Storage Policies sudah diatur\n'
                    '3. Bucket berstatus Public',
                buttonText: 'Mengerti',
              );
            }
            return;
          }
        } catch (e) {
          if (mounted) Navigator.pop(context); // Close loading

          if (mounted) {
            String errorMessage = 'Error upload gambar: $e';

            if (e.toString().contains('404')) {
              errorMessage =
                  '❌ Bucket "products" tidak ditemukan!\n\n'
                  'Lihat QUICK_SETUP_STORAGE.md';
            } else if (e.toString().contains('401') ||
                e.toString().contains('403')) {
              errorMessage =
                  '❌ Permission Denied!\n\n'
                  'Setup Storage Policies di Supabase.\n'
                  'Lihat QUICK_SETUP_STORAGE.md';
            }

            CustomDialog.show(
              context: context,
              type: DialogType.error,
              title: 'Upload Error',
              message: errorMessage,
              buttonText: 'Tutup',
            );
          }
          return;
        }
      }

      final updatedProduct = ProductModel(
        productId: widget.product.productId,
        nama: _name,
        deskripsi: _description,
        gambar: imageUrl,
        grade: _grade,
        harga: _price.toDouble(),
        stok: _stock,
        satuan: _unit,
        storeId: widget.product.storeId,
        createdAt: widget.product.createdAt,
      );

      // Update product to database
      try {
        await _productService.updateProduct(
          widget.product.productId!,
          updatedProduct,
        );

        if (mounted) {
          CustomDialog.show(
            context: context,
            type: DialogType.success,
            title: 'Berhasil!',
            message: '${updatedProduct.nama} berhasil diperbarui',
            buttonText: 'OK',
            onConfirm: () {
              context.pop('updated');
            },
          );
        }
      } catch (e) {
        if (mounted) {
          CustomDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Gagal!',
            message: 'Gagal memperbarui produk: $e',
            buttonText: 'OK',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? rejectionAlert;
    // Rejection reason tidak ada di model baru, gunakan dummy check
    rejectionAlert = null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (rejectionAlert != null) ...[
                rejectionAlert,
                const SizedBox(height: 16),
              ],

              // Image Preview
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : _currentImageUrl != null &&
                              _currentImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap untuk ubah gambar',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk pilih gambar',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nama Produk
              _buildTextFormField(
                label: 'Nama Produk',
                initialValue: _name,
                onSaved: (value) => _name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi Produk
              _buildTextFormField(
                label: 'Deskripsi Produk',
                initialValue: _description,
                maxLines: 4,
                onSaved: (value) => _description = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi produk tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harga dan Satuan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Harga
                  Expanded(
                    flex: 2,
                    child: _buildTextFormField(
                      label: 'Harga',
                      initialValue: formatRupiah(_price),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _price = unformatRupiah(value ?? '0'),
                      validator: (value) {
                        if (value == null || unformatRupiah(value) <= 0) {
                          return 'Harga harus lebih dari nol.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Satuan
                  Expanded(
                    flex: 1,
                    child: _buildDropdownField(
                      label: 'Satuan',
                      value: _unit,
                      items: availableUnits,
                      onChanged: (String? newValue) {
                        setState(() {
                          _unit = newValue!;
                        });
                      },
                      onSaved: (value) => _unit = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stok dan Grade
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stok
                  Expanded(
                    flex: 1,
                    child: _buildTextFormField(
                      label: 'Stok',
                      initialValue: _stock.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) =>
                          _stock = int.tryParse(value ?? '0') ?? 0,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Stok harus angka.';
                        }
                        if (int.tryParse(value)! < 0) {
                          return 'Stok tidak boleh minus.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Grade
                  Expanded(
                    flex: 2,
                    child: _buildDropdownField(
                      label: 'Grade Produk',
                      value: _grade,
                      items: availableGrades,
                      onChanged: (String? newValue) {
                        setState(() {
                          _grade = newValue!;
                        });
                      },
                      onSaved: (value) => _grade = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldSetter<String> onSaved,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      isExpanded: true,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }

  Widget _buildRejectionCard(String reason) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rejectedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rejectedColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '❗ Produk sebelumnya DITOLAK oleh Admin:',
            style: TextStyle(fontWeight: FontWeight.bold, color: rejectedColor),
          ),
          const SizedBox(height: 5),
          Text(reason, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 5),
          const Text(
            'Produk akan kembali ke status "Menunggu Verifikasi" setelah perubahan disimpan.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
