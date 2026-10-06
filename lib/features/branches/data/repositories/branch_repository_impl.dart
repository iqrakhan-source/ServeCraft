import '../datasources/branch_remote_data_source.dart';
import '../models/branch_model.dart';
import '../../domain/repositories/branch_repository.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource remoteDataSource;

  BranchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BranchModel>> getBranches({bool activeOnly = false}) async {
    return await remoteDataSource.getBranches(activeOnly: activeOnly);
  }

  @override
  Future<BranchModel> getBranchById(String id) async {
    return await remoteDataSource.getBranchById(id);
  }
}
