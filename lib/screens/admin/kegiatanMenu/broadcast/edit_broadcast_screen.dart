import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/broadcast_model.dart';
import 'package:jawara_pintar_kel_5/services/broadcast_service.dart';

class EditBroadcastScreen extends StatefulWidget {
  final BroadcastModel broadcast;

  const EditBroadcastScreen({
    Key? key,
    required this.broadcast,
  }) : super(key: key);

  @override
  State<EditBroadcastScreen> createState() => _EditBroadcastScreenState();
}

class _EditBroadcastScreenState extends State<EditBroadcastScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final BroadcastService _broadcastService = BroadcastService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.broadcast.judul);
    _contentController = TextEditingController(text: widget.broadcast.konten);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Simpan perubahan
  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedBroadcast = widget.broadcast.copyWith(
        judul: _titleController.text,
        konten: _contentController.text,
      );

      try {
        await _broadcastService.updateBroadcast(widget.broadcast.id!, updatedBroadcast);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Broadcast "${updatedBroadcast.judul}" berhasil diperbarui.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true on success

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui broadcast: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
                        onPressed: _isLoading ? null : _batalForm,
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
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: simpanColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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