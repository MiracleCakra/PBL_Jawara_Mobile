import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';
import 'package:jawara_pintar_kel_5/services/store_status_service.dart';
import 'store_dashboard.dart';

class WargaStoreLoginScreen extends StatefulWidget {
  const WargaStoreLoginScreen({super.key});

  @override
  State<WargaStoreLoginScreen> createState() => _WargaStoreLoginScreenState();
}

class _WargaStoreLoginScreenState extends State<WargaStoreLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Login Toko",
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
            const SizedBox(height: 20),
            _buildSubmitButton(context),
            const SizedBox(height: 10),
            _buildRegisterOption(context),
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
          Icon(Icons.storefront, size: 40, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "Selamat Datang Kembali",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Silakan login dengan email dan password Anda.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(
                controller: emailC,
                label: "Email",
                icon: Icons.email,
                keyboard: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
              ),
              const SizedBox(height: 14),
              _buildInput(
                controller: passwordC,
                label: "Password",
                icon: Icons.lock,
                keyboard: TextInputType.visiblePassword,
                validator: (v) => v!.isEmpty ? "Password wajib diisi" : null,
                obscureText: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboard,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Simulasi login
            await StoreStatusService.setStoreStatus(2);

            // Contoh data store yang bisa dikirim ke dashboard
            StoreModel myStore = StoreModel(
              name: "SSS, Sayur Segar Susanto",
              description:
                  "Menyediakan sayuran dan buah segar dari kebun lokal.",
              phone: "081234567890",
              address: "Jl. Anggrek No. 5, RT 001 / RW 001",
            );

            // Arahkan ke dashboard toko
           context.goNamed(
              'WargaMarketplaceHome',
              extra: myStore,
            );
          }
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF6A5AE0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "Login",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRegisterOption(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Belum punya akun? "),
          GestureDetector(
            onTap: () => context.goNamed('WargaStoreRegister'),
            child: const Text(
              "Daftar",
              style: TextStyle(
                color: Color(0xFF6A5AE0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
