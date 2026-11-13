import '../../../services/data/models/service_model.dart';
import '../../../services/data/models/service_products_response.dart';

class BookingCartItem {
  final ServiceModel service;
  final ConsumableProduct product;

  const BookingCartItem({required this.service, required this.product});

  double get totalPrice => service.startingPrice + product.addedPrice;

  int get totalDurationMinutes =>
      service.durationInMinutes + product.addedDuration;
}
