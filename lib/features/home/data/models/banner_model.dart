class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? discountTag;
  final String? actionRoute;
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.discountTag,
    this.actionRoute,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      discountTag: json['discountTag'] as String?,
      actionRoute: json['actionRoute'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'discountTag': discountTag,
      'actionRoute': actionRoute,
      'isActive': isActive,
    };
  }
}
