class IndividualChairModel {
  final int chairIndex;
  final String chairNumber;
  final bool isAvailable;
  final String status;

  const IndividualChairModel({
    required this.chairIndex,
    required this.chairNumber,
    this.isAvailable = true,
    this.status = 'Available',
  });

  factory IndividualChairModel.fromJson(Map<String, dynamic> json) {
    return IndividualChairModel(
      chairIndex: (json['chairIndex'] as num?)?.toInt() ?? 0,
      chairNumber: (json['chairNumber'] ?? '').toString(),
      isAvailable:
          json['isAvailable'] as bool? ??
          (json['status']?.toString().toLowerCase() == 'available'),
      status: (json['status'] ?? 'Available').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chairIndex': chairIndex,
      'chairNumber': chairNumber,
      'isAvailable': isAvailable,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndividualChairModel &&
          runtimeType == other.runtimeType &&
          chairIndex == other.chairIndex &&
          chairNumber == other.chairNumber;

  @override
  int get hashCode => Object.hash(chairIndex, chairNumber);
}

class ChairAvailabilityModel {
  final String branchId;
  final String date;
  final String timeSlot;
  final int totalChairs;
  final int occupiedChairs;
  final int availableChairs;
  final List<String> availableChairNames;
  final List<IndividualChairModel> chairs;
  final bool isFull;

  const ChairAvailabilityModel({
    required this.branchId,
    required this.date,
    required this.timeSlot,
    required this.totalChairs,
    required this.occupiedChairs,
    required this.availableChairs,
    this.availableChairNames = const [],
    this.chairs = const [],
    this.isFull = false,
  });

  factory ChairAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final total =
        (root['totalChairs'] as num?)?.toInt() ??
        (root['chairCount'] as num?)?.toInt() ??
        0;

    final occupied =
        (root['occupiedChairs'] as num?)?.toInt() ??
        (root['occupiedCount'] as num?)?.toInt() ??
        (root['bookedChairs'] is List
            ? (root['bookedChairs'] as List).length
            : 0);

    final availableList = root['availableChairs'] is List
        ? (root['availableChairs'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final available =
        (root['availableCount'] as num?)?.toInt() ??
        (availableList.isNotEmpty
            ? availableList.length
            : ((root['availableChairs'] as num?)?.toInt() ??
                  (total - occupied)));

    final full = root['isFull'] as bool? ?? (available <= 0);

    // Parse individual chairs
    List<IndividualChairModel> parsedChairs = [];
    final rawAllChairs = root['allChairs'] ?? root['chairs'];
    if (rawAllChairs is List && rawAllChairs.isNotEmpty) {
      parsedChairs = rawAllChairs
          .whereType<Map<String, dynamic>>()
          .map((m) => IndividualChairModel.fromJson(m))
          .toList();
    } else if (root['emptyChairs'] is List &&
        (root['emptyChairs'] as List).isNotEmpty) {
      final emptyList = (root['emptyChairs'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => IndividualChairModel.fromJson(m))
          .toList();
      parsedChairs = emptyList;
    } else if (availableList.isNotEmpty) {
      parsedChairs = availableList.asMap().entries.map((entry) {
        return IndividualChairModel(
          chairIndex: entry.key + 1,
          chairNumber: entry.value,
          isAvailable: true,
          status: 'Available',
        );
      }).toList();
    } else if (total > 0) {
      parsedChairs = List.generate(total, (index) {
        final numStr = (index + 1).toString().padLeft(2, '0');
        final isAvail = index < available;
        return IndividualChairModel(
          chairIndex: index + 1,
          chairNumber: 'Chair $numStr',
          isAvailable: isAvail,
          status: isAvail ? 'Available' : 'Occupied',
        );
      });
    }

    return ChairAvailabilityModel(
      branchId: (root['branchId'] ?? '').toString(),
      date: (root['date'] ?? '').toString(),
      timeSlot: (root['timeSlot'] ?? '').toString(),
      totalChairs: total,
      occupiedChairs: occupied,
      availableChairs: available,
      availableChairNames: availableList,
      chairs: parsedChairs,
      isFull: full,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'date': date,
      'timeSlot': timeSlot,
      'totalChairs': totalChairs,
      'occupiedChairs': occupiedChairs,
      'availableChairs': availableChairs,
      'availableChairNames': availableChairNames,
      'chairs': chairs.map((c) => c.toJson()).toList(),
      'isFull': isFull,
    };
  }
}
