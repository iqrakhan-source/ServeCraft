import 'package:prop_crm/features/waitlist/data/models/join_waitlist_response_model.dart';
import 'package:prop_crm/features/waitlist/data/models/waitlist_entry_model.dart';

abstract class WaitlistRepository {
  Future<JoinWaitlistResponseModel> joinWaitlist({
    required String branchId,
    required String serviceId,
    String? preferredTime,
    String? notes,
  });

  Future<List<WaitlistEntryModel>> getMyWaitlist();
}
