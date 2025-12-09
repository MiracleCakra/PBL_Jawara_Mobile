import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

class VegetableDetectionService {
  // Hugging Face Spaces: https://huggingface.co/spaces/MiracleCakra/CMKESEGARANSAYUR
  static const String baseUrl =
      'https://miraclecakra-cmkesegaransayur.hf.space';

  /// Deteksi kesegaran sayur dari gambar
  /// Returns: Map dengan prediction, confidence, dan details
  ///
  /// CATATAN PENTING:
  /// - Mobile hanya mengirim gambar yang sudah dinormalisasi (RGB, orientation-fixed)
  /// - Backend (main.py) yang melakukan semua preprocessing & prediction:
  ///   1. Resize 224x224 (cv2.INTER_LANCZOS4)
  ///   2. U2Net Segmentation (crop tight + black background)
  ///   3. Feature Extraction (1046 features: HSV, GLCM, LBP, HOG, etc)
  ///   4. LightGBM Prediction
  Future<Map<String, dynamic>> detectVegetableFreshness(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/predict');

      // STEP 1: Baca file original
      final originalBytes = await imageFile.readAsBytes();

      // STEP 2: Decode & Fix EXIF Orientation
      // Penting! Foto dari kamera phone bisa ter-rotate (landscape/portrait)
      // Codec akan otomatis fix berdasarkan EXIF metadata
      final codec = await ui.instantiateImageCodec(originalBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // STEP 3: Convert ke PNG (Lossless, RGB guaranteed)
      // Backend expects RGB format, PNG ensures:
      // - No compression artifacts (vs JPEG)
      // - Consistent color space (RGB, not BGR/YUV)
      // - Lossless quality
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // STEP 4: Kirim ke backend via multipart/form-data
      var request = http.MultipartRequest('POST', uri);

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        pngBytes,
        filename: 'vegetable.png',
        contentType: http_parser.MediaType('image', 'png'),
      );
      request.files.add(multipartFile);

      // DEBUG: Info preprocessing yang dilakukan
      print('🔍 DEBUG REQUEST (Mobile Preprocessing):');
      print('URL: $uri');
      print('Source: ${imageFile.path}');
      print('Original: ${originalBytes.length} bytes');
      print('Normalized PNG: ${pngBytes.length} bytes');
      print('Resolution: ${image.width}x${image.height}');
      print('Format: PNG (RGB, orientation-fixed, lossless)');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        // DEBUG: Print raw response untuk troubleshooting
        print('🔍 DEBUG RAW API RESPONSE:');
        print(response.body);
        print('🔍 Prediction: ${result['prediction']}');
        print('🔍 Confidence: ${result['confidence']}');
        print('🔍 Details: ${result['details']}');

        if (result['success'] == true) {
          return {
            'success': true,
            'prediction': result['prediction'], // "Segar", "Layu", "Busuk"
            'confidence': result['confidence'], // Confidence in percentage
            'details': result['details'], // Probability for each class
          };
        } else {
          return {
            'success': false,
            'error': result['error'] ?? 'Unknown error',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Check if API is online
  Future<bool> checkApiStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['status'] == 'Online';
      }
      return false;
    } catch (e) {
      print('API Check Error: $e');
      return false;
    }
  }

  /// Map prediction to grade
  /// Segar -> Grade A
  /// Layu -> Grade B
  /// Busuk -> Grade C
  String mapPredictionToGrade(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'segar':
        return 'Grade A';
      case 'layu':
        return 'Grade B';
      case 'busuk':
        return 'Grade C';
      default:
        return 'Grade A';
    }
  }

  /// Get color for prediction
  /// For UI feedback
  static Map<String, dynamic> getPredictionStyle(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'segar':
        return {
          'color': const Color(0xFF4CAF50), // Green
          'icon': '🌿',
          'message': 'Sayur dalam kondisi segar!',
        };
      case 'layu':
        return {
          'color': const Color(0xFFFF9800), // Orange
          'icon': '🍂',
          'message': 'Sayur mulai layu',
        };
      case 'busuk':
        return {
          'color': const Color(0xFFF44336), // Red
          'icon': '❌',
          'message': 'Sayur dalam kondisi busuk',
        };
      default:
        return {
          'color': const Color(0xFF9E9E9E), // Grey
          'icon': '❓',
          'message': 'Tidak dapat mendeteksi',
        };
    }
  }
}
