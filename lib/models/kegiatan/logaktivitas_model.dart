import 'package:flutter/material.dart';
import 'dart:async';

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

class LogAktivitas {
  final String judul;
  final String user;
  final String tanggal;
  final String type;
  LogAktivitas({
    required this.judul,
    required this.user,
    required this.tanggal,
    required this.type,
  });
}