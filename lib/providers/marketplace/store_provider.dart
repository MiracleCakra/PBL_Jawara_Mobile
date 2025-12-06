import 'package:flutter/material.dart';

import '../../models/marketplace/store_model.dart';
import '../../services/marketplace/store_service.dart';

class StoreProvider extends ChangeNotifier {
  final StoreService _storeService = StoreService();

  StoreModel? _currentStore;
  List<StoreModel> _stores = [];
  bool _isLoading = false;
  String? _errorMessage;

  StoreModel? get currentStore => _currentStore;
  List<StoreModel> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStoreByUserId(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentStore = await _storeService.getStoreByUserId(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStoreById(int storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentStore = await _storeService.getStoreById(storeId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllStores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stores = await _storeService.getAllStores();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPendingStores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stores = await _storeService.getPendingStores();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<StoreModel?> createStore(StoreModel store) async {
    try {
      final newStore = await _storeService.createStore(store);
      _currentStore = newStore;
      notifyListeners();
      return newStore;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStore(int storeId, StoreModel store) async {
    try {
      final updated = await _storeService.updateStore(storeId, store);
      _currentStore = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVerificationStatus(
    int storeId,
    String status, {
    String? alasan,
  }) async {
    try {
      await _storeService.updateVerificationStatus(
        storeId,
        status,
        alasan: alasan,
      );
      if (_currentStore?.storeId == storeId) {
        _currentStore = _currentStore?.copyWith(
          verifikasi: status,
          alasan: alasan,
        );
      }

      // Update in stores list if present
      final index = _stores.indexWhere((s) => s.storeId == storeId);
      if (index != -1) {
        _stores[index] = _stores[index].copyWith(
          verifikasi: status,
          alasan: alasan,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> searchStores({String? query, String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stores = await _storeService.searchStores(query: query, status: status);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStoresByStatus(String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (status == 'Semua') {
        _stores = await _storeService.getAllStores();
      } else {
        _stores = await _storeService.getStoresByStatus(status);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
