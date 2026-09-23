class TimeSlotModel {
  final String id;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String? displayLabel;

  const TimeSlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.displayLabel,
  });

  /// Display string, e.g. "09:00 AM - 10:00 AM"
  String get formattedLabel => displayLabel ?? '$startTime - $endTime';

  TimeSlotModel copyWith({
    String? id,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    String? displayLabel,
  }) {
    return TimeSlotModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      displayLabel: displayLabel ?? this.displayLabel,
    );
  }

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      displayLabel: json['displayLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'displayLabel': displayLabel,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlotModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          isAvailable == other.isAvailable &&
          displayLabel == other.displayLabel;

  @override
  int get hashCode =>
      id.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      isAvailable.hashCode ^
      displayLabel.hashCode;
}
