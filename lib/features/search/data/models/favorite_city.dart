class FavoriteCity {
  const FavoriteCity({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.sortOrder = 0,
  });

  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final int sortOrder;

  FavoriteCity copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    int? sortOrder,
  }) {
    return FavoriteCity(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'sort_order': sortOrder,
    };
  }

  factory FavoriteCity.fromMap(Map<String, dynamic> map) {
    return FavoriteCity(
      id: map['id'] as int?,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteCity &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, latitude, longitude, sortOrder);
  }
}
