import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../models/loyalty_transaction_model.dart';
import '../models/loyalty_wallet_model.dart';

abstract class LoyaltyRemoteDataSource {
  Future<LoyaltyWalletModel> getWallet();
  Future<List<LoyaltyTransactionModel>> getHistory({
    int page = 1,
    int limit = 20,
  });
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  final ApiClient apiService;

  LoyaltyRemoteDataSourceImpl({required this.apiService});

  @override
  Future<LoyaltyWalletModel> getWallet() async {
    final response = await apiService.get<LoyaltyWalletModel>(
      ApiConstants.loyaltyWallet,
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('Invalid loyalty wallet response');
        }
        return LoyaltyWalletModel.fromJson(Map<String, dynamic>.from(json));
      },
    );

    if (!response.success || response.data == null) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch loyalty wallet.',
      );
    }

    return response.data!;
  }

  @override
  Future<List<LoyaltyTransactionModel>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiService.get<List<LoyaltyTransactionModel>>(
      ApiConstants.loyaltyHistory,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        dynamic listJson;
        if (json is Map) {
          final data = json['data'];
          if (data is Map && data['transactions'] is List) {
            listJson = data['transactions'];
          } else if (data is List) {
            listJson = data;
          } else if (json['transactions'] is List) {
            listJson = json['transactions'];
          }
        } else if (json is List) {
          listJson = json;
        }

        if (listJson is! List) {
          return <LoyaltyTransactionModel>[];
        }

        return listJson
            .whereType<Map>()
            .map(
              (item) => LoyaltyTransactionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      },
    );

    if (!response.success) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch loyalty history.',
      );
    }

    return response.data ?? <LoyaltyTransactionModel>[];
  }
}
