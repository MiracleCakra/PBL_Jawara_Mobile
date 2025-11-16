import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'daftar_broadcast.dart';

class EditBroadcastScreen extends StatefulWidget {
  final KegiatanBroadcast initialBroadcastData;

  const EditBroadcastScreen({
    Key? key,
    required this.initialBroadcastData,
  }) : super(key: key);

  @override
  State<EditBroadcastScreen> createState() => _EditBroadcastScreenState();
}

class _EditBroadcastScreenState extends State<EditBroadcastScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialBroadcastData.judul);
    _contentController =
        TextEditingController(text: widget.initialBroadcastData.konten);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Simpan perubahan
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final newTitle = _titleController.text;
      final newContent = _contentController.text;
      Navigator.pop(context, {
        'status': 'updated',
        'judul': newTitle,
        'konten': newContent,
      });
    }
  }

  // Batal
  void _batalForm() {
    Navigator.pop(context);
  }

  // Widget input text field
  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool isRequired = true, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Kolom $label wajib diisi.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color simpanColor = Colors.deepPurple;
    final Color batalColor = Colors.grey.shade500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Edit Broadcast',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Divider(height: 1, color: Colors.grey),
        ),
      ),

      // Isi form
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField('Judul Broadcast', _titleController,
                  'Masukkan Judul Broadcast'),
              _buildTextField('Isi Broadcast', _contentController,
                  'Tuliskan isi pesan siaran di sini...',
                  maxLines: 8),
              
              const SizedBox(height: 32), 

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _batalForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: batalColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Tombol Simpan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: simpanColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10), 
            ],
          ),
        ),
      ),
    );
  }
}