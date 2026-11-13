enum PaymentMethodType {
  upi,
  card,
  cod;

  static PaymentMethodType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'upi':
        return PaymentMethodType.upi;
      case 'card':
        return PaymentMethodType.card;
      case 'cod':
      case 'cash':
      case 'cash_on_delivery':
      case 'salon':
      case 'pay_at_salon':
      case 'payatsalon':
      case 'pay at salon':
      case 'offline':
        return PaymentMethodType.cod;
      case 'online':
        return PaymentMethodType.upi;
      default:
        return PaymentMethodType.upi;
    }
  }

  bool get isPayAtSalon => this == PaymentMethodType.cod;
  bool get isOnline => this != PaymentMethodType.cod;

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
    final type = PaymentMethodType.fromString(
      (json['type'] ?? json['method'] ?? json['title'] ?? 'upi').toString(),
    );
    final defaultTitle = type == PaymentMethodType.cod
        ? 'Pay at Salon'
        : (type == PaymentMethodType.card
              ? 'Credit / Debit Card'
              : 'Online Payment');
    final defaultSubtitle = type == PaymentMethodType.cod
        ? 'Pay at Reception Desk'
        : 'Prepaid Online';

    return PaymentMethodModel(
      id:
          (json['id'] ??
                  json['_id'] ??
                  (type == PaymentMethodType.cod ? 'pm_salon' : 'pm_online'))
              .toString(),
      title: (json['title'] ?? json['name'] ?? defaultTitle).toString(),
      subtitle: (json['subtitle'] ?? defaultSubtitle).toString(),
      type: type,
      isAvailable: json['isAvailable'] as bool? ?? true,
      iconName: json['iconName'] as String?,
    );
  }

  factory PaymentMethodModel.fromDynamic(dynamic raw) {
    if (raw is PaymentMethodModel) {
      return raw;
    }
    if (raw is Map) {
      return PaymentMethodModel.fromJson(Map<String, dynamic>.from(raw));
    }
    final str = raw?.toString().trim() ?? '';
    final type = PaymentMethodType.fromString(str);
    final title = type == PaymentMethodType.cod
        ? 'Pay at Salon'
        : (type == PaymentMethodType.card
              ? 'Credit / Debit Card'
              : (str.toLowerCase().contains('upi')
                    ? 'UPI Payment'
                    : 'Online Payment'));
    final subtitle = type == PaymentMethodType.cod
        ? 'Pay at Reception Desk'
        : 'Prepaid Online';

    return PaymentMethodModel(
      id: type == PaymentMethodType.cod ? 'pm_salon' : 'pm_online',
      title: title,
      subtitle: subtitle,
      type: type,
      isAvailable: true,
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
