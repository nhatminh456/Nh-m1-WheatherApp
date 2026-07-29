class LocationModel {
  final int? id;
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final int sortOrder;
  final bool isDefault;

  const LocationModel({
    this.id,
    required this.name,
    this.displayName = '',
    required this.latitude,
    required this.longitude,
    this.sortOrder = 0,
    this.isDefault = false,
  });

  LocationModel copyWith({
    int? id,
    String? name,
    String? displayName,
    double? latitude,
    double? longitude,
    int? sortOrder,
    bool? isDefault,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get title => displayName.trim().isEmpty ? name : displayName.trim();

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      displayName: map['display_name'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      sortOrder: map['sort_order'] as int,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'latitude': latitude,
      'longitude': longitude,
      'sort_order': sortOrder,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
