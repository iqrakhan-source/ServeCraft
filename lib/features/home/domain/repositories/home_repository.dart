import 'package:prop_crm/features/home/data/models/home_data_model.dart';

abstract class HomeRepository {
  Future<HomeDataModel> getHomeData();
}
