class SongCollection {
  final String id;
  final String name;
  final Set<int> hymnNumbers;
  final DateTime createdAt;
  final DateTime updatedAt;

  SongCollection({
    required this.id,
    required this.name,
    required this.hymnNumbers,
    required this.createdAt,
    required this.updatedAt,
  });

  SongCollection copyWith({
    String? name,
    Set<int>? hymnNumbers,
    DateTime? updatedAt,
  }) {
    return SongCollection(
      id: id,
      name: name ?? this.name,
      hymnNumbers: hymnNumbers ?? this.hymnNumbers,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hymnNumbers': hymnNumbers.toList()..sort(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SongCollection.fromJson(Map<String, dynamic> json) {
    final numbers = (json['hymnNumbers'] as List<dynamic>? ?? const [])
        .map((e) => e is int ? e : int.tryParse(e.toString()))
        .whereType<int>()
        .toSet();

    return SongCollection(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'Untitled',
      hymnNumbers: numbers,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
