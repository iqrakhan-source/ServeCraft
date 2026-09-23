import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import '../models/service_model.dart';
import '../models/service_package_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServices({String? categoryId, String? query});
  Future<ServiceModel> getServiceById(String id);
  Future<List<ServicePackageModel>> getPackagesByServiceId(String serviceId);
}

/// Production implementation connecting to REST backend via ApiService
class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiService apiService;

  ServiceRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    String? query,
  }) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final response = await apiService.get<List<ServiceModel>>(
      ApiConstants.services,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return response.data ?? [];
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    final response = await apiService.get<ServiceModel>(
      ApiConstants.serviceById(id),
      fromJson: (json) => ServiceModel.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw NotFoundException(message: 'Service with id $id not found');
    }
    return response.data!;
  }

  @override
  Future<List<ServicePackageModel>> getPackagesByServiceId(
      String serviceId) async {
    final response = await apiService.get<List<ServicePackageModel>>(
      ApiConstants.packagesByServiceId(serviceId),
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) =>
                  ServicePackageModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return response.data ?? [];
  }
}

/// TEMPORARY: Isolated mock data source until live REST backend is deployed.
class MockServiceRemoteDataSource implements ServiceRemoteDataSource {
  final List<ServiceModel> _mockServices = [
    // Cleaning
    const ServiceModel(
      id: 'srv_deep_clean',
      categoryId: 'cat_cleaning',
      name: 'Full Home Deep Cleaning',
      description:
          'Thorough cleaning of floors, windows, kitchen, bathrooms, and high-touch areas with hospital-grade sanitizers.',
      image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600',
      rating: 4.85,
      reviewCount: 420,
      startingPrice: 1499.0,
      duration: '3 - 5 hrs',
      packages: [
        ServicePackageModel(
          id: 'pkg_clean_basic',
          serviceId: 'srv_deep_clean',
          name: 'Basic (1 BHK)',
          description: 'Dry vacuuming, floor mopping, kitchen wiping & bathroom clean',
          price: 1499.0,
          duration: '3 hrs',
          features: [
            '1 Bedroom & Living room deep clean',
            '1 Bathroom sanitization',
            'Dry vacuuming of carpets and sofas',
            'Floor scrubbing & mopping',
          ],
        ),
        ServicePackageModel(
          id: 'pkg_clean_std',
          serviceId: 'srv_deep_clean',
          name: 'Standard (2 BHK)',
          description: 'Intense scrubbing, degreasing, and detailed dusting',
          price: 2499.0,
          duration: '4.5 hrs',
          features: [
            '2 Bedrooms & Living room deep clean',
            '2 Bathrooms acid-free scrubbing',
            'Kitchen tile degreasing & chimney exterior',
            'Balcony floor washing',
            'Window panes & slider track vacuuming',
          ],
        ),
        ServicePackageModel(
          id: 'pkg_clean_premium',
          serviceId: 'srv_deep_clean',
          name: 'Premium (3 BHK / Villa)',
          description: 'Complete top-to-bottom deep cleaning with machine polishing',
          price: 3699.0,
          duration: '6 hrs',
          features: [
            '3+ Bedrooms & Living/Dining area',
            'Full Kitchen deep scrub + cabinet interiors',
            'All Bathrooms deep descaling',
            'Single disc machine floor scrubbing',
            'Odor neutralization & sanitization spray',
          ],
        ),
      ],
    ),
    const ServiceModel(
      id: 'srv_kitchen_clean',
      categoryId: 'cat_cleaning',
      name: 'Kitchen Deep Degreasing',
      description:
          'Oil and grease removal from stove, exhaust, tiles, sink, and exterior cabinet surfaces.',
      image: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
      rating: 4.78,
      reviewCount: 195,
      startingPrice: 599.0,
      duration: '2 hrs',
      packages: [
        ServicePackageModel(
          id: 'pkg_kitch_basic',
          serviceId: 'srv_kitchen_clean',
          name: 'Essential Kitchen Clean',
          description: 'Countertops, sink, and gas stove scrubbing',
          price: 599.0,
          duration: '1.5 hrs',
          features: ['Gas stove degreasing', 'Sink & tile cleaning', 'Trash can sanitization'],
        ),
        ServicePackageModel(
          id: 'pkg_kitch_deep',
          serviceId: 'srv_kitchen_clean',
          name: 'Heavy Oil & Chimney Degrease',
          description: 'Special chemical degreasing for sticky surfaces and cabinets',
          price: 999.0,
          duration: '2.5 hrs',
          features: [
            'Complete cabinet interior/exterior',
            'Chimney baffle filters deep wash',
            'Grout stain removal',
            'Microwave & fridge exterior clean',
          ],
        ),
      ],
    ),
    const ServiceModel(
      id: 'srv_bathroom_clean',
      categoryId: 'cat_cleaning',
      name: 'Bathroom Deep Sanitization',
      description:
          'Tile descaling, toilet pot disinfection, mirror polishing, and exhaust fan cleaning.',
      image: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600',
      rating: 4.90,
      reviewCount: 312,
      startingPrice: 399.0,
      duration: '1 hr',
      packages: [
        ServicePackageModel(
          id: 'pkg_bath_std',
          serviceId: 'srv_bathroom_clean',
          name: 'Standard Bathroom Scrub',
          description: 'Tile descaling, commode and sink washing',
          price: 399.0,
          duration: '1 hr',
          features: ['Hard water stain removal', 'Commode sanitization', 'Mirror & tap polishing'],
        ),
      ],
    ),

    // Appliances
    const ServiceModel(
      id: 'srv_ac_service',
      categoryId: 'cat_appliances',
      name: 'AC Master Servicing (Foam-Jet)',
      description:
          'High-pressure water pump cleaning, indoor cooling coil wash, filter cleaning, and gas leak check.',
      image: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600',
      rating: 4.88,
      reviewCount: 560,
      startingPrice: 599.0,
      duration: '1 hr',
      packages: [
        ServicePackageModel(
          id: 'pkg_ac_split',
          serviceId: 'srv_ac_service',
          name: 'Split AC Power Jet Clean',
          description: 'Complete 2x deeper cleaning with pressure jet & foam',
          price: 599.0,
          duration: '45 mins',
          features: [
            'Indoor cooling coil foam wash',
            'Drain tray & pipe flushing',
            'Outdoor unit water spray cleaning',
            'Gas level check & temperature test',
          ],
        ),
        ServicePackageModel(
          id: 'pkg_ac_gas',
          serviceId: 'srv_ac_service',
          name: 'AC Servicing + Gas Top-Up',
          description: 'Includes foam jet servicing plus refrigerant gas refill',
          price: 1899.0,
          duration: '1.5 hrs',
          features: [
            'Full Power Jet Servicing',
            'Nitrogen pressure testing',
            'Refrigerant gas top-up (R32 / R410A)',
            '60-day service guarantee',
          ],
        ),
      ],
    ),
    const ServiceModel(
      id: 'srv_washing_machine',
      categoryId: 'cat_appliances',
      name: 'Washing Machine Repair & Checkup',
      description: 'Diagnosis for drum spinning, drainage issues, motor noise, and water inlet problems.',
      image: 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=600',
      rating: 4.65,
      reviewCount: 140,
      startingPrice: 299.0,
      duration: '1 hr',
      packages: [
        ServicePackageModel(
          id: 'pkg_wm_checkup',
          serviceId: 'srv_washing_machine',
          name: 'Diagnosis & Inspection',
          description: 'Comprehensive physical and electrical inspection',
          price: 299.0,
          duration: '45 mins',
          features: ['Complete machine diagnostics', 'Quote for spare parts', 'Adjusted in final repair bill'],
        ),
      ],
    ),

    // Electrician
    const ServiceModel(
      id: 'srv_switchboard',
      categoryId: 'cat_electrician',
      name: 'Switchboard & Socket Installation',
      description: 'Modular switch replacement, socket installation, MCB trip troubleshooting, and earthing checks.',
      image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=600',
      rating: 4.82,
      reviewCount: 210,
      startingPrice: 199.0,
      duration: '45 mins',
      packages: [
        ServicePackageModel(
          id: 'pkg_switch_install',
          serviceId: 'srv_switchboard',
          name: 'Switch / Socket Replacement',
          description: 'Fix up to 2 switches or 1 socket board',
          price: 199.0,
          duration: '30 mins',
          features: ['Safety tester check', 'Tight connection wiring', '30-day warranty'],
        ),
      ],
    ),

    // Plumbing
    const ServiceModel(
      id: 'srv_tap_repair',
      categoryId: 'cat_plumbing',
      name: 'Tap & Pipe Leakage Repair',
      description: 'Fix dripping faucets, mixer taps, shower heads, and underground pipe leakages.',
      image: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=600',
      rating: 4.79,
      reviewCount: 380,
      startingPrice: 199.0,
      duration: '45 mins',
      packages: [
        ServicePackageModel(
          id: 'pkg_tap_fix',
          serviceId: 'srv_tap_repair',
          name: 'Tap Spindle / Washer Fix',
          description: 'Fix single leaky tap or cartridge replacement',
          price: 199.0,
          duration: '30 mins',
          features: ['Washer replacement', 'Teflon tape seal', 'Leak-proof test'],
        ),
      ],
    ),

    // Salon & Spa
    const ServiceModel(
      id: 'srv_salon_men',
      categoryId: 'cat_grooming',
      name: 'Haircut & Beard Styling for Men',
      description: 'Professional barber service at home with disposable towels and sanitized tools.',
      image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
      rating: 4.92,
      reviewCount: 650,
      startingPrice: 249.0,
      duration: '45 mins',
      packages: [
        ServicePackageModel(
          id: 'pkg_groom_combo',
          serviceId: 'srv_salon_men',
          name: 'Haircut + Beard Trim + Head Massage',
          description: 'Relaxing 3-in-1 grooming session',
          price: 499.0,
          duration: '60 mins',
          features: ['Haircut tailored to face shape', 'Beard shaping & styling', '10-min almond oil head massage'],
        ),
      ],
    ),
  ];

  @override
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<ServiceModel> results = _mockServices.where((s) => s.isActive);

    if (categoryId != null && categoryId.isNotEmpty) {
      results = results.where((s) => s.categoryId == categoryId);
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((s) =>
          s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q));
    }

    return results.toList();
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockServices.firstWhere((s) => s.id == id);
    } catch (_) {
      throw NotFoundException(message: 'Service with id $id not found');
    }
  }

  @override
  Future<List<ServicePackageModel>> getPackagesByServiceId(
      String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final service = await getServiceById(serviceId);
    return service.packages;
  }
}
