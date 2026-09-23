class AddressModel {
  final String id;
  final String userId;
  final String label;
  final String houseNumber;
  final String addressLine;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.houseNumber,
    required this.addressLine,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  /// Complete single-line formatted address
  String get formattedAddress {
    final buffer = StringBuffer('$houseNumber, $addressLine');
    if (landmark != null && landmark!.trim().isNotEmpty) {
      final clean = landmark!.trim();
      if (clean.toLowerCase().startsWith('near ')) {
        buffer.write(', $clean');
      } else {
        buffer.write(', Near $clean');
      }
    }
    buffer.write(', $city, $state - $pincode');
    return buffer.toString();
  }

  /// Compact address preview (house + street)
  String get shortAddress => '$houseNumber, $addressLine';

  /// City, State and PIN summary
  String get localitySummary => '$city, $state - $pincode';

  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? houseNumber,
    String? addressLine,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      houseNumber: houseNumber ?? this.houseNumber,
      addressLine: addressLine ?? this.addressLine,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      label: json['label'] as String? ?? 'Home',
      houseNumber: json['houseNumber'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      landmark: json['landmark'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'houseNumber': houseNumber,
      'addressLine': addressLine,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          label == other.label &&
          houseNumber == other.houseNumber &&
          addressLine == other.addressLine &&
          landmark == other.landmark &&
          city == other.city &&
          state == other.state &&
          pincode == other.pincode &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          isDefault == other.isDefault;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      label.hashCode ^
      houseNumber.hashCode ^
      addressLine.hashCode ^
      landmark.hashCode ^
      city.hashCode ^
      state.hashCode ^
      pincode.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      isDefault.hashCode;
}
