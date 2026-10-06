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
  static final List<ServiceModel> _mockServices = [
    // 1. Executive Haircut & Styling
    const ServiceModel(
      id: 'srv_exec_haircut',
      categoryId: 'cat_hair_styling',
      name: "Executive Haircut & Styling",
      description:
          'Precision scissor or clipper haircut customized to your face profile, followed by an invigorating hair wash, scalp massage, and blow-dry styling.',
      image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
      rating: 4.9,
      reviewCount: 380,
      startingPrice: 499.0,
      duration: '45 mins',
      genderTarget: 'men',
      inclusions: [
        'Hair consultation with senior stylist',
        'Organic clarifying wash',
        'Precision haircut & beard edge trimming',
        'Cool-blast blow dry & matte clay styling',
      ],
      packages: [
        ServicePackageModel(
          id: 'pkg_haircut_classic',
          serviceId: 'srv_exec_haircut',
          name: 'Classic Haircut',
          description: 'Haircut, hair wash & quick blow dry',
          price: 499.0,
          duration: '30 mins',
          features: ['Cut', 'Wash', 'Dry'],
        ),
        ServicePackageModel(
          id: 'pkg_haircut_luxe',
          serviceId: 'srv_exec_haircut',
          name: 'Executive Cut & Scalp Therapy',
          description: 'Haircut, wash, 15-min therapeutic head massage & premium styling',
          price: 799.0,
          duration: '45 mins',
          features: ['Cut', 'Head Massage', 'Wash', 'Styling'],
        ),
      ],
    ),

    // 2. Women's Signature Cut & Blow Dry
    const ServiceModel(
      id: 'srv_women_haircut',
      categoryId: 'cat_hair_styling',
      name: "Signature Cut & Blow Dry",
      description:
          'Transformative haircuts by creative directors. Includes luxury shampoo, deep conditioning mask, and custom blowout styling.',
      image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600',
      rating: 4.88,
      reviewCount: 512,
      startingPrice: 899.0,
      duration: '60 mins',
      genderTarget: 'women',
      inclusions: [
        'Style consultation',
        'Kerastase cleansing & nourishing mask',
        'Precision layer / bob / curtain cut',
        'Volume blow dry & heat shield setting',
      ],
      packages: [
        ServicePackageModel(
          id: 'pkg_women_basic',
          serviceId: 'srv_women_haircut',
          name: 'Signature Cut & Dry',
          description: 'Cut, wash, and sleek blowout',
          price: 899.0,
          duration: '45 mins',
          features: ['Cut', 'Wash', 'Blowout'],
        ),
        ServicePackageModel(
          id: 'pkg_women_deluxe',
          serviceId: 'srv_women_haircut',
          name: 'Cut, Conditioning & Tong Waves',
          description: 'Cut, deep conditioning, and glam beach waves styling',
          price: 1299.0,
          duration: '60 mins',
          features: ['Cut', 'Deep Conditioning', 'Glam Waves'],
        ),
      ],
    ),

    // 3. Hydra Deep Facial
    const ServiceModel(
      id: 'srv_hydra_facial',
      categoryId: 'cat_facial',
      name: 'Hydra Medi-Facial & Glow Therapy',
      description:
          'Advanced multi-step facial utilizing suction vortex technology to extract impurities, deeply hydrate, and infuse potent hyaluronic serums.',
      image: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=600',
      rating: 4.95,
      reviewCount: 290,
      startingPrice: 1799.0,
      duration: '60 mins',
      genderTarget: 'all',
      inclusions: [
        'Hydro-dermabrasion deep pore cleansing',
        'Painless blackhead suction extraction',
        'Antioxidant & hyaluronic acid infusion',
        'LED light collagen rejuvenation therapy',
      ],
      packages: [
        ServicePackageModel(
          id: 'pkg_hydra_express',
          serviceId: 'srv_hydra_facial',
          name: 'Express Hydra Clean-up',
          description: 'Pore cleaning & rapid hydration',
          price: 1799.0,
          duration: '45 mins',
          features: ['Pore Cleaning', 'Hydration Infusion'],
        ),
        ServicePackageModel(
          id: 'pkg_hydra_gold',
          serviceId: 'srv_hydra_facial',
          name: 'Gold Glow Medi-Facial',
          description: 'Full vortex exfoliation, gold serum infusion & peel-off rubber mask',
          price: 2499.0,
          duration: '60 mins',
          features: ['Hydro-dermabrasion', 'Gold Serum', 'Rubber Mask', 'LED Light'],
        ),
      ],
    ),

    // 4. Moroccan Argan Hair Spa
    const ServiceModel(
      id: 'srv_moroccan_spa',
      categoryId: 'cat_spa',
      name: 'Moroccan Argan Hair Spa',
      description:
          'Deep nourishing hair repair therapy enriched with 100% pure Moroccan Argan Oil to tame frizz, repair heat damage, and restore silky shine.',
      image: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600',
      rating: 4.82,
      reviewCount: 215,
      startingPrice: 1299.0,
      duration: '60 mins',
      genderTarget: 'all',
      inclusions: [
        'Scalp diagnosis & clarifying wash',
        'Steam-activated Argan cream massage',
        'Ultra-repair hair serum infusion',
        'Smoothing blowout finish',
      ],
      packages: [
        ServicePackageModel(
          id: 'pkg_spa_aroma',
          serviceId: 'srv_moroccan_spa',
          name: 'Aromatherapy Hair Spa',
          description: 'Nourishing cream treatment & warm ozone steam',
          price: 1299.0,
          duration: '45 mins',
          features: ['Steam', 'Nourishing Cream', 'Head Massage'],
        ),
        ServicePackageModel(
          id: 'pkg_spa_moroccan',
          serviceId: 'srv_moroccan_spa',
          name: 'Intense Argan Reconstruction',
          description: 'Moroccan oil treatment, 25-min acupressure massage & leave-in gloss',
          price: 1899.0,
          duration: '60 mins',
          features: ['Argan Oil', 'Acupressure Massage', 'Ozone Steam', 'Gloss Blowout'],
        ),
      ],
    ),

    // 5. Luxury Gel Manicure & Pedicure
    const ServiceModel(
      id: 'srv_gel_mani_pedi',
      categoryId: 'cat_nails',
      name: 'Luxury Gel Manicure & Pedicure Combo',
      description:
          'Complete pampering for hands and feet: sea salt soak, exfoliating scrub, cuticle grooming, moisturizing massage, and chip-free gel polish.',
      image: 'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=600',
      rating: 4.79,
      reviewCount: 168,
      startingPrice: 1499.0,
      duration: '75 mins',
      genderTarget: 'women',
      inclusions: [
        'Aromatic Epsom salt foot & hand bath',
        'Dead skin exfoliation with organic walnut scrub',
        'Nail shaping, cuticle trimming & buffing',
        'Long-lasting UV gel color application',
      ],
      packages: [
        ServicePackageModel(
          id: 'pkg_pedi_express',
          serviceId: 'srv_gel_mani_pedi',
          name: 'Classic Mani-Pedi',
          description: 'Essential grooming & regular polish',
          price: 999.0,
          duration: '45 mins',
          features: ['Soak', 'Exfoliation', 'Nail Grooming', 'Regular Polish'],
        ),
        ServicePackageModel(
          id: 'pkg_gel_combo',
          serviceId: 'srv_gel_mani_pedi',
          name: 'Deluxe Gel Spa Combo',
          description: 'Paraffin wax hydration, scrub, reflexology massage & UV gel polish',
          price: 1699.0,
          duration: '75 mins',
          features: ['Paraffin Wax', 'Reflexology', 'UV Gel Polish'],
        ),
      ],
    ),

    // 6. Royal Beard Grooming
    const ServiceModel(
      id: 'srv_beard_spa',
      categoryId: 'cat_grooming',
      name: 'Royal Beard Spa & Hot Towel Shave',
      description:
          'Classic straight razor shaving with hot eucalyptus towels, pre-shave essential oils, precision beard sculpting, and aftershave balm.',
      image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
      rating: 4.86,
      reviewCount: 340,
      startingPrice: 399.0,
      duration: '30 mins',
      genderTarget: 'men',
      inclusions: [
        'Hot towel pore opening',
        'Botanical pre-shave oil massage',
        'Straight razor contour shaping',
        'Cooling witch hazel balm',
      ],
      packages: [
        ServicePackageModel(
          id: 'pkg_beard_trim',
          serviceId: 'srv_beard_spa',
          name: 'Classic Beard Sculpting',
          description: 'Trimming, line-up & beard butter conditioning',
          price: 399.0,
          duration: '20 mins',
          features: ['Trim', 'Edge Line-up', 'Beard Butter'],
        ),
        ServicePackageModel(
          id: 'pkg_royal_shave',
          serviceId: 'srv_beard_spa',
          name: 'Royal Hot Towel Experience',
          description: 'Double hot towel, cutthroat razor shave, face massage & cologne finish',
          price: 599.0,
          duration: '35 mins',
          features: ['Double Hot Towel', 'Razor Shave', 'Face Massage', 'Cologne'],
        ),
      ],
    ),

    // 7. Legacy test service (to ensure existing test suites succeed seamlessly)
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
          features: ['Vacuuming', 'Mopping', 'Bathroom Cleaning'],
        ),
      ],
    ),
  ];

  @override
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = List<ServiceModel>.from(_mockServices);

    if (categoryId != null && categoryId.isNotEmpty) {
      results = results.where((s) => s.categoryId == categoryId).toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q))
          .toList();
    }

    return results;
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _mockServices.firstWhere((s) => s.id == id);
    } catch (_) {
      throw NotFoundException(message: 'Service with id $id not found');
    }
  }

  @override
  Future<List<ServicePackageModel>> getPackagesByServiceId(
      String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final service = await getServiceById(serviceId);
    return service.packages;
  }
}
