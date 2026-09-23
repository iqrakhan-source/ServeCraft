enum PaymentMethodType {
  upi,
  card,
  cod;

  static PaymentMethodType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'upi':
        return PaymentMethodType.upi;
      case 'card':
        return PaymentMethodType.card;
      case 'cod':
      case 'cash_on_delivery':
        return PaymentMethodType.cod;
      default:
        return PaymentMethodType.upi;
    }
  }

  String toFormattedString() {
    switch (this) {
      case PaymentMethodType.upi:
        return 'upi';
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.cod:
        return 'cod';
    }
  }
}

class PaymentMethodModel {
  final String id;
  final String title;
  final String subtitle;
  final PaymentMethodType type;
  final bool isAvailable;
  final String? iconName;

  const PaymentMethodModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isAvailable = true,
    this.iconName,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    PaymentMethodType? type,
    bool? isAvailable,
    String? iconName,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      iconName: iconName ?? this.iconName,
    );
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      type: PaymentMethodType.fromString(json['type'] as String? ?? 'upi'),
      isAvailable: json['isAvailable'] as bool? ?? true,
      iconName: json['iconName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.toFormattedString(),
      'isAvailable': isAvailable,
      'iconName': iconName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          subtitle == other.subtitle &&
          type == other.type &&
          isAvailable == other.isAvailable &&
          iconName == other.iconName;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      subtitle.hashCode ^
      type.hashCode ^
      isAvailable.hashCode ^
      iconName.hashCode;
}
