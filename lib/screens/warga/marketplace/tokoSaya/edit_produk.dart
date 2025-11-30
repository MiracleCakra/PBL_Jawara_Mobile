import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah, unformatRupiah;

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

  late String _name;
  late String _description;
  late int _price;
  late int _stock;
  late String _grade;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _description = widget.product.description;
    _price = widget.product.price;
    _stock = widget.product.stock;
    _grade = widget.product.grade;
    _unit = widget.product.unit;
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // TODO: Panggil provider.updateProduct(newProduct) di sini

      final updatedProduct = ProductModel(
        id: widget.product.id,
        name: _name,
        description: _description,
        imageUrl: widget.product.imageUrl,
        grade: _grade,
        price: _price,
        rating: widget.product.rating,
        isVerified: false,
        stock: _stock,
        unit: _unit,
        rejectionReason: null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${updatedProduct.name} berhasil diperbarui.'),
            backgroundColor: Colors.grey.shade800),
      );

      context.pop(updatedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? rejectionAlert;
    if (widget.product.rejectionReason != null &&
        widget.product.rejectionReason!.isNotEmpty) {
      rejectionAlert = _buildRejectionCard(widget.product.rejectionReason!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSaved: (value) =>
                          _price = unformatRupiah(value ?? '0'),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      isExpanded: true,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
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
          const Text('❗ Produk sebelumnya DITOLAK oleh Admin:',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: rejectedColor)),
          const SizedBox(height: 5),
          Text(reason, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 5),
          const Text(
            'Produk akan kembali ke status "Menunggu Verifikasi" setelah perubahan disimpan.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }
}
