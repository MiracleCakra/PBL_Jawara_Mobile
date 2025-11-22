import 'package:flutter/material.dart';
import 'dart:async';

class ActiveProductItem {
  final String id;
  final String productName;
  final String sellerName;
  final String category;
  final String imageUrl;
  final String timeUploaded;
  final String cvResult;
  final double cvConfidence;
  final String status;

  const ActiveProductItem({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.category,
    required this.imageUrl,
    required this.timeUploaded,
    required this.cvResult,
    required this.cvConfidence,
    required this.status,
  });

  ActiveProductItem copyWith({
    String? status,
  }) {
    return ActiveProductItem(
      id: id,
      productName: productName,
      sellerName: sellerName,
      category: category,
      imageUrl: imageUrl,
      timeUploaded: timeUploaded,
      cvResult: cvResult,
      cvConfidence: cvConfidence,
      status: status ?? this.status,
    );
  }
}

// KELAS DEBOUNCER (DISIMULASIKAN KARENA DIGUNAKAN)
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}