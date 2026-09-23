import 'time_slot_model.dart';

class ServiceDateModel {
  final DateTime date;
  final bool isAvailable;
  final String? unavailableReason;
  final List<TimeSlotModel> slots;

  const ServiceDateModel({
    required this.date,
    this.isAvailable = true,
    this.unavailableReason,
    this.slots = const [],
  });

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Short day display name: "Today", "Tomorrow", or 3-letter weekday
  String get dayName {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  /// Day number, e.g. "25"
  String get dayNumber => date.day.toString();

  /// 3-letter month name, e.g. "Sep"
  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[date.month - 1];
  }

  /// Key in YYYY-MM-DD format
  String get dateKey {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Total available slots for this date
  int get availableSlotsCount => slots.where((s) => s.isAvailable).length;

  ServiceDateModel copyWith({
    DateTime? date,
    bool? isAvailable,
    String? unavailableReason,
    List<TimeSlotModel>? slots,
  }) {
    return ServiceDateModel(
      date: date ?? this.date,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableReason: unavailableReason ?? this.unavailableReason,
      slots: slots ?? this.slots,
    );
  }

  factory ServiceDateModel.fromJson(Map<String, dynamic> json) {
    return ServiceDateModel(
      date: DateTime.parse(json['date'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
      unavailableReason: json['unavailableReason'] as String?,
      slots: (json['slots'] as List<dynamic>?)
              ?.map((item) =>
                  TimeSlotModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'isAvailable': isAvailable,
      'unavailableReason': unavailableReason,
      'slots': slots.map((s) => s.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceDateModel &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          isAvailable == other.isAvailable &&
          unavailableReason == other.unavailableReason;

  @override
  int get hashCode =>
      date.year.hashCode ^
      date.month.hashCode ^
      date.day.hashCode ^
      isAvailable.hashCode ^
      unavailableReason.hashCode;
}
