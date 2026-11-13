import '../../data/models/stylist_model.dart';

abstract class StylistRepository {
  Future<List<StylistModel>> getStylists({
    required String branchId,
    String? serviceId,
    String? date,
    String? timeSlot,
  });
}
