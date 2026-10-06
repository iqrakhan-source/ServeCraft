import '../models/branch_model.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> getBranches({bool activeOnly = false});
  Future<BranchModel> getBranchById(String id);
}

class MockBranchRemoteDataSource implements BranchRemoteDataSource {
  static final List<BranchModel> _mockBranches = [
    const BranchModel(
      id: 'br_downtown',
      name: 'Downtown Luxury Lounge',
      address: '102 Park Avenue, 2nd Floor, Central District, Bengaluru',
      phone: '+91 98765 43210',
      rating: 4.9,
      reviewCount: 428,
      imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
      workingDays: [1, 2, 3, 4, 5, 6, 7], // Mon-Sun
      openingTime: '09:00',
      closingTime: '21:00',
      isActive: true,
      amenities: ['Valet Parking', 'Free Wi-Fi', 'Complimentary Beverage', 'Private VIP Suite', 'AC'],
    ),
    const BranchModel(
      id: 'br_uptown',
      name: 'Uptown Style Studio',
      address: '45 Lavelle Road, Near UB City, Bengaluru',
      phone: '+91 98765 43211',
      rating: 4.8,
      reviewCount: 310,
      imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
      workingDays: [1, 2, 3, 4, 5, 6], // Mon-Sat, closed Sunday
      openingTime: '10:00',
      closingTime: '20:30',
      isActive: true,
      amenities: ['Free Wi-Fi', 'Express Chairs', 'Beverages', 'AC'],
    ),
    const BranchModel(
      id: 'br_metro',
      name: 'Metro Salon & Spa',
      address: '77 100ft Road, Indiranagar, Bengaluru',
      phone: '+91 98765 43212',
      rating: 4.7,
      reviewCount: 195,
      imageUrl: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80',
      workingDays: [1, 2, 3, 4, 5, 6, 7],
      openingTime: '09:30',
      closingTime: '21:30',
      isActive: true,
      amenities: ['Valet Parking', 'Spa Jacuzzi', 'Organic Products', 'AC'],
    ),
    const BranchModel(
      id: 'br_westside_closed',
      name: 'Westside Beauty Bar (Temporarily Closed)',
      address: '18 Malleshwaram 8th Cross, Bengaluru',
      phone: '+91 98765 43213',
      rating: 4.5,
      reviewCount: 88,
      imageUrl: 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&w=800&q=80',
      workingDays: [1, 2, 3, 4, 5],
      openingTime: '10:00',
      closingTime: '19:00',
      isActive: false, // Deactivated branch
      amenities: ['AC', 'Free Wi-Fi'],
    ),
  ];

  @override
  Future<List<BranchModel>> getBranches({bool activeOnly = false}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (activeOnly) {
      return _mockBranches.where((b) => b.isActive).toList();
    }
    return List.from(_mockBranches);
  }

  @override
  Future<BranchModel> getBranchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final match = _mockBranches.firstWhere(
      (b) => b.id == id,
      orElse: () => _mockBranches.first,
    );
    return match;
  }
}
