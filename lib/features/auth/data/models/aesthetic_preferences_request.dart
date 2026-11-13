class AestheticPreferencesRequest {
  final String? email;
  final String? skinTone;
  final String? hairTone;
  final List<String>? allergies;

  const AestheticPreferencesRequest({
    this.email,
    this.skinTone,
    this.hairTone,
    this.allergies,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null && email!.isNotEmpty) 'email': email,
      if (skinTone != null && skinTone!.isNotEmpty) 'skinTone': skinTone,
      if (hairTone != null && hairTone!.isNotEmpty) 'hairTone': hairTone,
      if (allergies != null) 'allergies': allergies,
    };
  }

  factory AestheticPreferencesRequest.fromJson(Map<String, dynamic> json) {
    return AestheticPreferencesRequest(
      email: json['email'] as String?,
      skinTone: json['skinTone'] as String?,
      hairTone: json['hairTone'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
