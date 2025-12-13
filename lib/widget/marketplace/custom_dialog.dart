import 'package:flutter/material.dart';

enum DialogType { success, error, warning, info }

class CustomDialog {
  static void show({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    final theme = _getDialogTheme(type);

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme['color'].withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan background color
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: theme['color'].withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(theme['icon'], size: 48, color: theme['color']),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onConfirm != null) {
                        onConfirm();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme['color'],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText ?? 'OK',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Map<String, dynamic> _getDialogTheme(DialogType type) {
    switch (type) {
      case DialogType.success:
        return {
          'color': const Color(0xFF6A5AE0), // Ungu tema utama
          'icon': Icons.check_circle,
        };
      case DialogType.error:
        return {'color': const Color(0xFFE53935), 'icon': Icons.cancel};
      case DialogType.warning:
        return {'color': const Color(0xFFFF9800), 'icon': Icons.warning_amber};
      case DialogType.info:
        return {'color': const Color(0xFF6A5AE0), 'icon': Icons.info};
    }
  }
}

// Custom Snackbar with better design
class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required DialogType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = _getSnackbarTheme(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(theme['icon'], color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme['color'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        elevation: 4,
      ),
    );
  }

  static Map<String, dynamic> _getSnackbarTheme(DialogType type) {
    switch (type) {
      case DialogType.success:
        return {
          'color': const Color(0xFF6A5AE0),
          'icon': Icons.check_circle,
        }; // Ungu tema utama
      case DialogType.error:
        return {'color': const Color(0xFFE53935), 'icon': Icons.cancel};
      case DialogType.warning:
        return {'color': const Color(0xFFFF9800), 'icon': Icons.warning};
      case DialogType.info:
        return {'color': const Color(0xFF6A5AE0), 'icon': Icons.info};
    }
  }
}

// Custom Confirmation Dialog dengan 2 tombol (Batal & Aksi)
class CustomConfirmDialog {
  static Future<bool?> show({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String message,
    String cancelText = 'Batal',
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) async {
    final theme = _getDialogTheme(type);

    return await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme['color'].withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan background color
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: theme['color'].withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(theme['icon'], size: 48, color: theme['color']),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          if (onConfirm != null) {
                            onConfirm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: theme['color'],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Map<String, dynamic> _getDialogTheme(DialogType type) {
    switch (type) {
      case DialogType.success:
        return {'color': const Color(0xFF6A5AE0), 'icon': Icons.check_circle};
      case DialogType.error:
        return {'color': const Color(0xFFE53935), 'icon': Icons.cancel};
      case DialogType.warning:
        return {'color': const Color(0xFFFF9800), 'icon': Icons.warning_amber};
      case DialogType.info:
        return {'color': const Color(0xFF6A5AE0), 'icon': Icons.info};
    }
  }
}
