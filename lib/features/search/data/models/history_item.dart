class HistoryItem {
  const HistoryItem({
    this.id,
    required this.query,
    this.isFavorite = false,
    required this.searchedAt,
  });

  final int? id;
  final String query;
  final bool isFavorite;
  final DateTime searchedAt;

  HistoryItem copyWith({
    int? id,
    String? query,
    bool? isFavorite,
    DateTime? searchedAt,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      query: query ?? this.query,
      isFavorite: isFavorite ?? this.isFavorite,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'query': query,
      'is_favorite': isFavorite ? 1 : 0,
      'searched_at': searchedAt.millisecondsSinceEpoch,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] as int?,
      query: map['query'] as String,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      searchedAt: DateTime.fromMillisecondsSinceEpoch(map['searched_at'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryItem &&
        other.id == id &&
        other.query == query &&
        other.isFavorite == isFavorite &&
        other.searchedAt == searchedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, query, isFavorite, searchedAt);
  }
}
