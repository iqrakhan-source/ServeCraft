import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../models/join_waitlist_response_model.dart';
import '../models/waitlist_entry_model.dart';

abstract class WaitlistRemoteDataSource {
  Future<JoinWaitlistResponseModel> joinWaitlist({
    required String branchId,
    required String serviceId,
    String? preferredTime,
    String? notes,
  });

  Future<List<WaitlistEntryModel>> getMyWaitlist();
}

class WaitlistRemoteDataSourceImpl implements WaitlistRemoteDataSource {
  final ApiClient apiClient;

  WaitlistRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<JoinWaitlistResponseModel> joinWaitlist({
    required String branchId,
    required String serviceId,
    String? preferredTime,
    String? notes,
  }) async {
    final response = await apiClient.post<JoinWaitlistResponseModel>(
      ApiConstants.joinWaitlist,
      data: {
        'branchId': branchId,
        'serviceId': serviceId,
        if (preferredTime != null && preferredTime.trim().isNotEmpty)
          'preferredTime': preferredTime.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('Invalid join waitlist response');
        }
        return JoinWaitlistResponseModel.fromJson(
          Map<String, dynamic>.from(json),
        );
      },
    );

    if (!response.success || response.data == null) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to join waitlist.',
      );
    }

    return response.data!;
  }

  @override
  Future<List<WaitlistEntryModel>> getMyWaitlist() async {
    final response = await apiClient.get<List<WaitlistEntryModel>>(
      ApiConstants.myWaitlist,
      fromJson: (json) {
        dynamic listJson;

        if (json is List) {
          listJson = json;
        } else if (json is Map) {
          listJson = json['data'] ?? json['waitlist'];
        }

        if (listJson is! List) {
          return <WaitlistEntryModel>[];
        }

        return listJson
            .whereType<Map>()
            .map(
              (item) =>
                  WaitlistEntryModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      },
    );

    if (!response.success) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch waitlist entries.',
      );
    }

    return response.data ?? <WaitlistEntryModel>[];
  }
}
