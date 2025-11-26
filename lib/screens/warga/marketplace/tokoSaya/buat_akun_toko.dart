import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WargaStoreRegisterScreen extends StatefulWidget {
  const WargaStoreRegisterScreen({super.key});

  @override
  State<WargaStoreRegisterScreen> createState() =>
      _WargaStoreRegisterScreenState();
}

class _WargaStoreRegisterScreenState extends State<WargaStoreRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaTokoC = TextEditingController();
  final TextEditingController deskripsiC = TextEditingController();
  final TextEditingController lokasiC = TextEditingController();
  final TextEditingController noHpC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Daftar Toko",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),

            const SizedBox(height: 20),

            _buildFormCard(),

            const SizedBox(height: 30),

            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF8EA3F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.store_mall_directory,
              size: 40, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "Buka Usaha di Marketplace Warga",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Daftarkan toko Anda dan mulai menjual produk ke warga sekitar.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput(
                controller: namaTokoC,
                label: "Nama Toko",
                icon: Icons.storefront,
                validator: (v) =>
                    v!.isEmpty ? "Nama toko wajib diisi" : null,
              ),
              const SizedBox(height: 14),

              _buildInput(
                controller: deskripsiC,
                label: "Deskripsi Toko",
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) =>
                    v!.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              const SizedBox(height: 14),

              _buildInput(
                controller: lokasiC,
                label: "Lokasi (RT/RW)",
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    v!.isEmpty ? "Lokasi wajib diisi" : null,
              ),
              const SizedBox(height: 14),

              _buildInput(
                controller: noHpC,
                label: "No. HP / WhatsApp",
                icon: Icons.call_outlined,
                keyboard: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? "Nomor HP wajib diisi" : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Input
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),
      ),
    );
  }


  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Pendaftaran toko berhasil! Menunggu validasi admin."),
              ),
            );

            context.goNamed("StorePendingValidation");
          }
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF6A5AE0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Daftar Sekarang",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
