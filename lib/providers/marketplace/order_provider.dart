import 'package:flutter/material.dart';
import '../../models/marketplace/order_model.dart';
import '../../models/marketplace/order_item_model.dart';
import '../../services/marketplace/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  List<OrderItemModel> _currentOrderItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  List<OrderItemModel> get currentOrderItems => _currentOrderItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrdersByUserId(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrderItems(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentOrderItems = await _orderService.getOrderItems(orderId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      final newOrder = await _orderService.createOrder(order);
      _orders.insert(0, newOrder);
      notifyListeners();
      return newOrder;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createOrderItem(OrderItemModel orderItem) async {
    try {
      await _orderService.createOrderItem(orderItem);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      int index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(orderStatus: newStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  OrderModel? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((o) => o.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
