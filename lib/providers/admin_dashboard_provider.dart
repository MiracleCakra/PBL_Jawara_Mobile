import 'package:flutter/material.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final List<String> pages = ['Keuangan', 'Kegiatan', 'Kependudukan', 'Marketplace'];

  int _page = 0;
  int get page => _page;
  set page(int value) {
    _page = value;
    notifyListeners();
  }

  int _year = DateTime.now().year;
  int get year => _year;
  set year(int value) {
    _year = value;
    notifyListeners();
  }
}
