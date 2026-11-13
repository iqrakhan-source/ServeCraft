import '../../domain/repositories/loyalty_repository.dart';
import '../datasources/loyalty_remote_data_source.dart';
import '../models/loyalty_transaction_model.dart';
import '../models/loyalty_wallet_model.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final LoyaltyRemoteDataSource remoteDataSource;

  LoyaltyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LoyaltyWalletModel> getWallet() {
    return remoteDataSource.getWallet();
  }

  @override
  Future<List<LoyaltyTransactionModel>> getHistory({
    int page = 1,
    int limit = 20,
  }) {
    return remoteDataSource.getHistory(page: page, limit: limit);
  }
}
