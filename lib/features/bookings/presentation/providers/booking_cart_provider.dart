import 'package:flutter/foundation.dart';

import '../../data/models/booking_cart_item.dart';

class BookingCartProvider extends ChangeNotifier {
  final List<BookingCartItem> _items = [];

  List<BookingCartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalPrice =>
      _items.fold(0.0, (total, item) => total + item.totalPrice);

  int get totalDurationMinutes =>
      _items.fold(0, (total, item) => total + item.totalDurationMinutes);

  bool containsService(String serviceId) {
    return _items.any((item) => item.service.id == serviceId);
  }

  void addService({required BookingCartItem item}) {
    final index = _items.indexWhere(
      (existing) => existing.service.id == item.service.id,
    );

    if (index >= 0) {
      // Replace the product selection for this service.
      _items[index] = item;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void removeService(String serviceId) {
    _items.removeWhere((item) => item.service.id == serviceId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
