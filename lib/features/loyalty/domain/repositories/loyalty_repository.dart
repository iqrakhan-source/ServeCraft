import 'package:prop_crm/features/loyalty/data/models/loyalty_transaction_model.dart';
import 'package:prop_crm/features/loyalty/data/models/loyalty_wallet_model.dart';

abstract class LoyaltyRepository {
  Future<LoyaltyWalletModel> getWallet();
  Future<List<LoyaltyTransactionModel>> getHistory({
    int page = 1,
    int limit = 20,
  });
}
