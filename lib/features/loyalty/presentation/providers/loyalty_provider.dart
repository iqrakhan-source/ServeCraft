import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/loyalty_transaction_model.dart';
import '../../data/models/loyalty_wallet_model.dart';
import '../../domain/repositories/loyalty_repository.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyRepository repository;

  LoyaltyProvider({required this.repository});

  ViewState<LoyaltyWalletModel> _walletState = ViewState.initial();
  ViewState<LoyaltyWalletModel> get walletState => _walletState;
  LoyaltyWalletModel? get wallet => _walletState.data;

  ViewState<List<LoyaltyTransactionModel>> _historyState = ViewState.initial();
  ViewState<List<LoyaltyTransactionModel>> get historyState => _historyState;
  List<LoyaltyTransactionModel> get transactions => _historyState.data ?? [];

  bool get isLoading => _walletState.isLoading || _historyState.isLoading;

  Future<void> loadWallet() async {
    _walletState = ViewState.loading();
    notifyListeners();

    try {
      final data = await repository.getWallet();
      _walletState = ViewState.success(data);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _walletState = ViewState.error(appError.message);
    }

    notifyListeners();
  }

  Future<void> loadHistory({int page = 1, int limit = 20}) async {
    _historyState = ViewState.loading();
    notifyListeners();

    try {
      final data = await repository.getHistory(page: page, limit: limit);
      _historyState = ViewState.success(data);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _historyState = ViewState.error(appError.message);
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([loadWallet(), loadHistory()]);
  }
}
