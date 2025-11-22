import 'package:flutter/material.dart';
import 'dart:async';

const Color unguColor = Color(0xFF6366F1);

class ActiveProductItem {
  final String id;
  final String productName;
  final String sellerName;
  final String category;
  final String timeUploaded;
  final String cvResult; 
  final double cvConfidence; 
  final String status;
  final String imageUrl;
  final String description; 
  final int stock;
  final double price;

  const ActiveProductItem({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.category,
    this.status = 'Pending', 
    required this.imageUrl,
    this.timeUploaded = 'Baru saja',
    this.cvResult = 'Tidak ada hasil CV',
    this.cvConfidence = 0.0,
    this.description = 'Deskripsi produk ini sangat menarik dan detail. Ditanam dengan metode organik dan bebas pestisida.',
    this.stock = 50,
    this.price = 15000.0,
  });

  ActiveProductItem copyWith({
    String? status,
  }) {
    return ActiveProductItem(
      id: id,
      productName: productName,
      sellerName: sellerName,
      category: category,
      status: status ?? this.status,
      imageUrl: imageUrl,
      timeUploaded: timeUploaded,
      cvResult: cvResult,
      cvConfidence: cvConfidence,
      description: description,
      stock: stock,
      price: price,
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}