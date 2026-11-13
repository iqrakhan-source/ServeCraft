import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../models/stylist_model.dart';

abstract class StylistRemoteDataSource {
  Future<List<StylistModel>> getStylists({
    required String branchId,
    String? serviceId,
    String? date,
    String? timeSlot,
  });
}

class StylistRemoteDataSourceImpl implements StylistRemoteDataSource {
  final ApiClient apiClient;

  StylistRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<StylistModel>> getStylists({
    required String branchId,
    String? serviceId,
    String? date,
    String? timeSlot,
  }) async {
    final queryParams = <String, dynamic>{
      'branchId': branchId,
      if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
      if (date != null && date.isNotEmpty) 'date': date,
      if (timeSlot != null && timeSlot.isNotEmpty) 'timeSlot': timeSlot,
    };

    try {
      final response = await apiClient.get<List<StylistModel>>(
        ApiConstants.stylists,
        queryParameters: queryParams,
        fromJson: (json) {
          final root =
              json is Map && json.containsKey('data') && json['data'] != null
              ? json['data']
              : json;

          dynamic listRaw;
          if (root is Map) {
            listRaw = root['stylists'] ?? root['data'];
          } else if (root is List) {
            listRaw = root;
          }

          if (listRaw is List) {
            return listRaw
                .whereType<Map>()
                .map((m) => StylistModel.fromJson(Map<String, dynamic>.from(m)))
                .toList();
          }

          return <StylistModel>[];
        },
      );

      return response.data ?? [];
    } catch (e) {
      debugPrint('Failed to load stylists for branch $branchId: $e');
      return [];
    }
  }
}
