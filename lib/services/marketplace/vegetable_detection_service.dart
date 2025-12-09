import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

class VegetableDetectionService {

  // Hugging Face Spaces: https://huggingface.co/spaces/MiracleCakra/CMKESEGARANSAYUR
  static const String baseUrl =
      'https://miraclecakra-cmkesegaransayur.hf.space';

  /// Deteksi kesegaran sayur dari gambar
  /// Returns: Map dengan prediction, confidence, dan details
  Future<Map<String, dynamic>> detectVegetableFreshness(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/predict');

      // Baca file original
      final originalBytes = await imageFile.readAsBytes();

      // Create multipart request - KIRIM FILE ORIGINAL tanpa modifikasi
      var request = http.MultipartRequest('POST', uri);

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        originalBytes,
        filename: 'image.jpg',
        contentType: http_parser.MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      // DEBUG: Print request info
      print('🔍 DEBUG REQUEST:');
      print('URL: $uri');
      print('File path: ${imageFile.path}');
      print('File size: ${originalBytes.length} bytes');

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
