import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/services/marketplace/store_verification_helper.dart';

/// Widget wrapper that checks store verification status before allowing access
class StoreVerifiedWrapper extends StatefulWidget {
  final Widget child;
  final bool requireVerification;

  const StoreVerifiedWrapper({
    super.key,
    required this.child,
    this.requireVerification = true,
  });

  @override
  State<StoreVerifiedWrapper> createState() => _StoreVerifiedWrapperState();
}

class _StoreVerifiedWrapperState extends State<StoreVerifiedWrapper> {
  bool _isChecking = true;
  bool _isVerified = false;
  String? _statusMessage;
  String? _status;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (!widget.requireVerification) {
      setState(() {
        _isChecking = false;
        _isVerified = true;
      });
      return;
    }

    final statusCheck = await StoreVerificationHelper.checkStoreStatus();

    setState(() {
      _isChecking = false;
      _isVerified = statusCheck['isVerified'];
      _statusMessage = statusCheck['message'];
      _status = statusCheck['status'];
    });

    if (!_isVerified && mounted) {
      // Show dialog and go back
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          StoreVerificationHelper.showStoreStatusDialog(
            context: context,
            status: _status ?? 'unknown',
            message: _statusMessage ?? 'Status toko tidak diketahui',
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) context.pop();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa status toko...'),
            ],
          ),
        ),
      );
    }

    if (!_isVerified) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Akses Ditolak',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage ?? 'Toko Anda belum terverifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
