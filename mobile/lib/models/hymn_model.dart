class Hymn {
  final int number;
  final String title;
  final String category;
  final List<HymnSection> sections;
  final String version;
  final DateTime? updatedAt;
  final bool hasMusic;
  final DateTime? musicUpdatedAt;

  Hymn({
    required this.number,
    required this.title,
    required this.category,
    required this.sections,
    this.version = '1.0',
    this.updatedAt,
    this.hasMusic = false,
    this.musicUpdatedAt,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    final rawNumber = json['number'] ?? json['id'];
    final parsedNumber = rawNumber is int
        ? rawNumber
        : int.tryParse(rawNumber?.toString() ?? '') ?? 0;

    final rawSections = json['sections'] ?? json['content']?['sections'];
    final parsedSections = (rawSections as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HymnSection.fromJson)
        .toList();

    return Hymn(
      number: parsedNumber,
      title: json['title'] as String? ?? 'Untitled',
      category: json['category'] as String? ?? 'General',
      sections: parsedSections,
      version: json['version']?.toString() ?? '1.0',
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      hasMusic: json['hasMusic'] == true,
      musicUpdatedAt: DateTime.tryParse(
        json['musicUpdatedAt']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'title': title,
    'category': category,
    'sections': sections.map((section) => section.toJson()).toList(),
    'version': version,
    'updatedAt': updatedAt?.toIso8601String(),
    'hasMusic': hasMusic,
    'musicUpdatedAt': musicUpdatedAt?.toIso8601String(),
  };
}

class HymnSection {
  final String type; // INT, VRS, CHR, OTR
  final List<String> lines;

  HymnSection({required this.type, required this.lines});

  factory HymnSection.fromJson(Map<String, dynamic> json) {
    return HymnSection(
      type: json['type'] as String,
      lines: List<String>.from(json['lines'] as List<dynamic>),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'INT':
        return 'Seensa';
      case 'VRS':
        return 'Boqonnaa';
      case 'CHR':
        return 'Faarfannaa';
      default:
        return '';
    }
  }

  Map<String, dynamic> toJson() => {'type': type, 'lines': lines};
}
