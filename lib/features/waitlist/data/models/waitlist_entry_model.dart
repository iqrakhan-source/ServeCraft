class WaitlistEntryModel {
  final String id;
  final String branchName;
  final String? serviceName;
  final int queuePosition;
  final String status;
  final DateTime? createdAt;

  const WaitlistEntryModel({
    required this.id,
    required this.branchName,
    this.serviceName,
    required this.queuePosition,
    required this.status,
    this.createdAt,
  });

  factory WaitlistEntryModel.fromJson(Map<String, dynamic> json) {
    String branchName = '';
    if (json['branch'] is Map) {
      branchName = (json['branch']['name'] ?? '').toString();
    } else if (json['branch'] is String) {
      branchName = json['branch'] as String;
    }

    String? serviceName;
    if (json['service'] is Map) {
      serviceName = (json['service']['name'] ?? '').toString();
    }

    final createdStr = json['createdAt']?.toString();

    return WaitlistEntryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      branchName: branchName.isNotEmpty ? branchName : 'Salon Branch',
      serviceName: serviceName,
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 1,
      status: (json['status'] ?? 'waiting').toString(),
      createdAt: createdStr != null ? DateTime.tryParse(createdStr) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchName': branchName,
      if (serviceName != null) 'serviceName': serviceName,
      'queuePosition': queuePosition,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
